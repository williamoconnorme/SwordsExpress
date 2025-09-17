import Foundation
import MapKit
import CryptoKit

@MainActor
final class RouteSnappingService {
    static let shared = RouteSnappingService()

    // In-memory cache: key -> [CLLocationCoordinate2D]
    private var memoryCache: [String: [CLLocationCoordinate2D]] = [:]

    // Disk cache location
    private let cacheDirectory: URL = {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dir = url.appendingPathComponent("RouteSnappingCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {}

    // Public API: Snap a whole segment (sequence of coordinates) to roads, with caching.
    func snappedSegment(routeID: String, directionID: String, raw: [CLLocationCoordinate2D]) async throws -> [CLLocationCoordinate2D] {
        guard raw.count >= 2 else { return raw }

        let key = cacheKey(routeID: routeID, directionID: directionID, coords: raw)

        if let cached = memoryCache[key] {
            return cached
        }
        if let disk = loadFromDisk(key: key) {
            memoryCache[key] = disk
            return disk
        }

        let snapped = try await snapPolyline(raw)
        memoryCache[key] = snapped
        saveToDisk(key: key, coords: snapped)
        return snapped
    }

    // MARK: - Snapping logic

    private func snapPolyline(_ coords: [CLLocationCoordinate2D]) async throws -> [CLLocationCoordinate2D] {
        if #available(iOS 18.0, *) {
            return try await snapUsingWaypoints(coords)
        } else {
            return try await snapByLegs(coords)
        }
    }

    @available(iOS 18.0, *)
    private func snapUsingWaypoints(_ coords: [CLLocationCoordinate2D]) async throws -> [CLLocationCoordinate2D] {
        guard coords.count >= 2 else { return coords }

        // Sub-sample the coordinates to reduce the number of routing calls while preserving shape.
        // Keep first and last; pick every Nth in-between.
        let strideN = max(1, coords.count / 25) // target ~<=25 points
        var keypoints: [CLLocationCoordinate2D] = []
        keypoints.reserveCapacity(min(coords.count, 25))
        for (idx, c) in coords.enumerated() {
            if idx == 0 || idx == coords.count - 1 || (idx % strideN == 0) {
                keypoints.append(c)
            }
        }
        if let lastKey = keypoints.last, let lastCoord = coords.last, !lastKey.isApproximatelyEqual(to: lastCoord) {
            keypoints.append(lastCoord)
        }

        // Route between successive keypoints and stitch polylines together.
        var snapped: [CLLocationCoordinate2D] = []
        snapped.reserveCapacity(coords.count)
        for i in 0..<(keypoints.count - 1) {
            let a = keypoints[i]
            let b = keypoints[i + 1]

            let request = MKDirections.Request()
            request.source = MKMapItem(location: CLLocation(latitude: a.latitude, longitude: a.longitude), address: nil)
            request.destination = MKMapItem(location: CLLocation(latitude: b.latitude, longitude: b.longitude), address: nil)
            request.transportType = .automobile

            let directions = MKDirections(request: request)
            let response = try await directions.calculate()
            if let route = response.routes.first {
                let leg = route.polyline.coordinates
                if snapped.isEmpty {
                    snapped.append(contentsOf: leg)
                } else {
                    snapped.append(contentsOf: leg.dropFirst())
                }
            } else {
                // Fallback to straight segment if routing fails for this leg
                if snapped.isEmpty {
                    snapped.append(a)
                }
                snapped.append(b)
            }
        }
        return snapped.isEmpty ? coords : snapped
    }

    private func snapByLegs(_ coords: [CLLocationCoordinate2D]) async throws -> [CLLocationCoordinate2D] {
        var result: [CLLocationCoordinate2D] = []
        result.reserveCapacity(coords.count)

        for i in 0..<(coords.count - 1) {
            let a = coords[i]
            let b = coords[i + 1]
            let leg = try await routeLeg(from: a, to: b)
            if result.isEmpty {
                result.append(contentsOf: leg)
            } else {
                result.append(contentsOf: leg.dropFirst())
            }
        }
        return result
    }

    private func routeLeg(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async throws -> [CLLocationCoordinate2D] {
        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: from.latitude, longitude: from.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: to.latitude, longitude: to.longitude), address: nil)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()
        guard let route = response.routes.first else { return [from, to] }
        return route.polyline.coordinates
    }

    // MARK: - Caching

    private func cacheKey(routeID: String, directionID: String, coords: [CLLocationCoordinate2D]) -> String {
        var hasher = SHA256()
        hasher.update(data: Data((routeID + "|" + directionID).utf8))
        for c in coords {
            withUnsafeBytes(of: c.latitude.bitPattern) { hasher.update(data: Data($0)) }
            withUnsafeBytes(of: c.longitude.bitPattern) { hasher.update(data: Data($0)) }
        }
        let digest = hasher.finalize().map { String(format: "%02x", $0) }.joined()
        return digest
    }

    private func saveToDisk(key: String, coords: [CLLocationCoordinate2D]) {
        let url = cacheDirectory.appendingPathComponent(key).appendingPathExtension("json")
        let array = coords.map { ["lat": $0.latitude, "lon": $0.longitude] }
        do {
            let data = try JSONSerialization.data(withJSONObject: array, options: [])
            try data.write(to: url, options: .atomic)
        } catch {
            print("RouteSnappingService: saveToDisk failed: \(error)")
        }
    }

    private func loadFromDisk(key: String) -> [CLLocationCoordinate2D]? {
        let url = cacheDirectory.appendingPathComponent(key).appendingPathExtension("json")
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let raw = try? JSONSerialization.jsonObject(with: data) as? [[String: Double]] else { return nil }
        let coords = raw.compactMap { dict -> CLLocationCoordinate2D? in
            guard let lat = dict["lat"], let lon = dict["lon"] else { return nil }
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return coords.isEmpty ? nil : coords
    }
}

private extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: .init(), count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

private extension CLLocationCoordinate2D {
    /// Approximate equality check for coordinates with a small epsilon (in degrees).
    /// This avoids requiring Equatable conformance while being robust to tiny floating-point differences.
    func isApproximatelyEqual(to other: CLLocationCoordinate2D, epsilon: CLLocationDegrees = 1e-9) -> Bool {
        abs(latitude - other.latitude) <= epsilon && abs(longitude - other.longitude) <= epsilon
    }
}


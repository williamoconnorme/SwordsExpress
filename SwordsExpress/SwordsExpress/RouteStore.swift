import Foundation
import MapKit
import SwiftUI
import Combine

// MARK: - Decodable models matching routes.json
struct RoutesPayload: Decodable {
    let routes: [RouteDefinition]
}

struct RouteDefinition: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let colors: ColorsDefinition?
    let directions: [DirectionDefinition]
}

struct ColorsDefinition: Decodable, Hashable {
    let primary: String?
}

struct DirectionDefinition: Decodable, Identifiable, Hashable {
    let id: String // "toSwords" | "toCity"
    let name: String
    let polylines: [[Coordinate]]
    let stops: [StopDefinition]?
}

struct Coordinate: Decodable, Hashable {
    let lat: Double
    let lon: Double
}

struct StopDefinition: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
}

// MARK: - Loader
@MainActor
final class RouteStore: ObservableObject {
    @Published private(set) var routes: [RouteDefinition] = []

    init() {}

    func loadFromBundle(fileName: String = "routes", fileExtension: String = "json") throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else {
            throw NSError(domain: "RouteStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "routes.json not found in bundle"]) }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let payload = try decoder.decode(RoutesPayload.self, from: data)
        self.routes = payload.routes
    }

    func route(withID id: String) -> RouteDefinition? {
        routes.first { $0.id == id }
    }

    func polylineCoordinates(for routeID: String, directionID: String) -> [[CLLocationCoordinate2D]] {
        guard let route = route(withID: routeID) else { return [] }
        guard let dir = route.directions.first(where: { $0.id == directionID }) else { return [] }
        return dir.polylines.map { segment in
            segment.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
        }
    }
}

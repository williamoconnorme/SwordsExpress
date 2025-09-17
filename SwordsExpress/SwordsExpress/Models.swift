import Foundation
import MapKit
import SwiftUI

// MARK: - Core Models
struct BusStop: Identifiable, Hashable {
    let id: Int
    let name: String
    /// URL-safe identifier (predefined; do NOT derive from `name` at runtime to avoid mismatches)
    let slug: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: BusStop, rhs: BusStop) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Route: Identifiable, Hashable {
    let id: String
    let name: String
}

enum RouteDirection: String, CaseIterable, Identifiable {
    case toSwords = "To Swords"
    case toCity = "To City"
    var id: String { rawValue }
}

struct Bus: Identifiable, Hashable, Equatable {
    let id: String
    var coordinate: CLLocationCoordinate2D
    var bearing: Double
    var speed: String?
    var lastUpdated: Date?
    var compass: String?
    var inService: Bool

    static func == (lhs: Bus, rhs: Bus) -> Bool {
        lhs.id == rhs.id &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.speed == rhs.speed &&
        lhs.inService == rhs.inService &&
        lhs.compass == rhs.compass
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        let lat = Int(coordinate.latitude * 10_000)
        let lon = Int(coordinate.longitude * 10_000)
        hasher.combine(lat)
        hasher.combine(lon)
    }
}

struct TimetableEntry: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let route: String
}

// MARK: - Static Stops Data
enum StopsData {
    static let toCity: [BusStop] = [
        BusStop(id: 333,  name: "Abbeyvale",                slug: "abbeyvale",             coordinate: .init(latitude: 53.4596654, longitude: -6.2503624)),
        BusStop(id: 334,  name: "Swords Manor",             slug: "swords-manor",          coordinate: .init(latitude: 53.459984,  longitude: -6.245307)),
        BusStop(id: 339,  name: "Valley View",              slug: "valley-view",           coordinate: .init(latitude: 53.4606895, longitude: -6.2413665)),
        BusStop(id: 338,  name: "The Gallops",              slug: "the-gallops",           coordinate: .init(latitude: 53.4625433, longitude: -6.2398851)),
        BusStop(id: 337,  name: "Lios Cian",                slug: "lions-cian",             coordinate: .init(latitude: 53.463878,  longitude: -6.239549)),
        BusStop(id: 336,  name: "Cianlea",                  slug: "cianlea",               coordinate: .init(latitude: 53.4657815, longitude: -6.2397887)),
        BusStop(id: 1234, name: "Laurelton",                slug: "laurelton",             coordinate: .init(latitude: 53.468251,  longitude: -6.2367971)),
        BusStop(id: 340,  name: "Applewood Estate",         slug: "applewood-estate",             coordinate: .init(latitude: 53.4694079, longitude: -6.2308137)),
        BusStop(id: 341,  name: "Jugback Lane",             slug: "jugback-lane",               coordinate: .init(latitude: 53.4686893, longitude: -6.2279908)),
        BusStop(id: 342,  name: "Saint Colmcille's GFC",    slug: "saint-colmcilles-gfc",     coordinate: .init(latitude: 53.4682362, longitude: -6.2209795)),
        BusStop(id: 343,  name: "West Seatown",             slug: "west-seatown",          coordinate: .init(latitude: 53.4650053, longitude: -6.2173297)),
        BusStop(id: 344,  name: "Seatown Road",             slug: "seatown-road",          coordinate: .init(latitude: 53.4622247, longitude: -6.2131752)),
        BusStop(id: 345,  name: "Swords Bypass",            slug: "swords-bypass",         coordinate: .init(latitude: 53.4569384, longitude: -6.2124503)),
        BusStop(id: 582,  name: "Malahide Roundabout",      slug: "malahide-roundabout",          coordinate: .init(latitude: 53.454165,  longitude: -6.215768)),
        BusStop(id: 347,  name: "Pavilions Shopping Centre",slug: "pavilions-shopping-centre",             coordinate: .init(latitude: 53.454629,  longitude: -6.2183)),
        BusStop(id: 348,  name: "Dublin Road (Penneys)",    slug: "dublin-road-penneys",     coordinate: .init(latitude: 53.4558985, longitude: -6.2217432)),
        BusStop(id: 583,  name: "Highfields",               slug: "highfields",            coordinate: .init(latitude: 53.4543519, longitude: -6.2243928)),
        BusStop(id: 587,  name: "Ballintrane",              slug: "ballintrane",           coordinate: .init(latitude: 53.4526008, longitude: -6.2272095)),
        BusStop(id: 351,  name: "Boroimhe Laurels",         slug: "boroimhe-laurels",      coordinate: .init(latitude: 53.4455748, longitude: -6.2352678)),
        BusStop(id: 352,  name: "Boroimhe Maples",          slug: "boroimhe-maples",       coordinate: .init(latitude: 53.444665,  longitude: -6.231174)),
        BusStop(id: 353,  name: "Airside Road",             slug: "airside-road",            coordinate: .init(latitude: 53.4449935, longitude: -6.2271727)),
        BusStop(id: 354,  name: "Airside Central",          slug: "airside-central",       coordinate: .init(latitude: 53.446006,  longitude: -6.2243145)),
        BusStop(id: 355,  name: "Holywell Distributor Road",slug: "holywell-distributor-road",         coordinate: .init(latitude: 53.443639,  longitude: -6.2111045)),
        BusStop(id: 356,  name: "M1 Drinan",                slug: "m1-drinan",             coordinate: .init(latitude: 53.4434736, longitude: -6.2093203)),
        BusStop(id: 357,  name: "East Wall Road",           slug: "east-wall-road",          coordinate: .init(latitude: 53.3507872, longitude: -6.2259726)),
        BusStop(id: 584,  name: "Convention Centre",        slug: "convention-centre",     coordinate: .init(latitude: 53.3474227, longitude: -6.2397389)),
        BusStop(id: 585,  name: "Seán O'Casey Bridge",      slug: "sean-o-casey-pedestrian-bridge",    coordinate: .init(latitude: 53.3479217, longitude: -6.247108)),
        BusStop(id: 586,  name: "Eden Quay",                slug: "eden-quay",             coordinate: .init(latitude: 53.348063,  longitude: -6.25635))
    ]

    static let toSwords: [BusStop] = [
        BusStop(id: 555,   name: "Eden Quay",                            slug: "eden-quay",             coordinate: .init(latitude: 53.3477969, longitude: -6.2584213)),
        BusStop(id: 556,   name: "IFSC",                                 slug: "ifsc",                  coordinate: .init(latitude: 53.3482716, longitude: -6.2502319)),
        BusStop(id: 557,   name: "Custom House Quay (Jury's)",           slug: "custom-house-quay-jurys",             coordinate: .init(latitude: 53.3481121, longitude: -6.2472811)),
        BusStop(id: 558,   name: "Custom House Quay (Clarion)",          slug: "custom-house-quay-clarion",           coordinate: .init(latitude: 53.3477493, longitude: -6.2423821)),
        BusStop(id: 559,   name: "North Wall Quay",                      slug: "north-wall-quay",       coordinate: .init(latitude: 53.3473521, longitude: -6.2364198)),
        BusStop(id: 560,   name: "Point Depot (North Wall Quay)",        slug: "point-depot-north-wall-quay",       coordinate: .init(latitude: 53.346875,  longitude: -6.228919)),
        BusStop(id: 562,   name: "Holywell Distributor Road",            slug: "holywell-distributor-road",         coordinate: .init(latitude: 53.4434416, longitude: -6.2111721)),
        BusStop(id: 563,   name: "Airside Central",                      slug: "airside-central",       coordinate: .init(latitude: 53.446133,  longitude: -6.222701)),
        BusStop(id: 564,   name: "Boroimhe Maples",                      slug: "boroimhe-maples",       coordinate: .init(latitude: 53.444509,  longitude: -6.231292)),
        BusStop(id: 565,   name: "Boroimhe Laurels",                     slug: "boroimhe-laurels",      coordinate: .init(latitude: 53.445133,  longitude: -6.235007)),
        BusStop(id: 566,   name: "Ballintrane",                          slug: "ballintrane",           coordinate: .init(latitude: 53.4521321, longitude: -6.2286058)),
        BusStop(id: 567,   name: "Highfields",                           slug: "highfields",            coordinate: .init(latitude: 53.4544301, longitude: -6.224466)),
        BusStop(id: 568,   name: "Dublin Road (opp Penneys)",            slug: "dublin-road-opp-penneys",     coordinate: .init(latitude: 53.45538,   longitude: -6.222422)),
        BusStop(id: 569,   name: "Malahide Roundabout",                  slug: "malahide-roundabout",          coordinate: .init(latitude: 53.454339,  longitude: -6.216293)),
        BusStop(id: 570,   name: "Seatown Road",                         slug: "seatown-road",          coordinate: .init(latitude: 53.461677,  longitude: -6.2134949)),
        BusStop(id: 571,   name: "West Seatown",                         slug: "west-seatown",          coordinate: .init(latitude: 53.464877,  longitude: -6.2169974)),
        BusStop(id: 572,   name: "Saint Colmcille's GFC",                slug: "saint-colmcilles-gfc",     coordinate: .init(latitude: 53.4680775, longitude: -6.2215895)),
        BusStop(id: 573,   name: "Jugback Lane",                         slug: "jugback-lane",               coordinate: .init(latitude: 53.4684694, longitude: -6.2275828)),
        BusStop(id: 574,   name: "Applewood Estate",                     slug: "applewood-estate",             coordinate: .init(latitude: 53.4695937, longitude: -6.2318054)),
        BusStop(id: 575,   name: "Laurelton",                            slug: "laurelton",             coordinate: .init(latitude: 53.4683705, longitude: -6.2362437)),
        BusStop(id: 576,   name: "Cianlea",                               slug: "cianlea",               coordinate: .init(latitude: 53.4666115, longitude: -6.2392209)),
        BusStop(id: 577,   name: "Ardcian",                               slug: "ardcian",               coordinate: .init(latitude: 53.4656155, longitude: -6.2396175)),
        BusStop(id: 578,   name: "Lios Cian",                             slug: "lios-cian",             coordinate: .init(latitude: 53.4641399, longitude: -6.239343)),
        BusStop(id: 579,   name: "Valley View",                          slug: "valley-view",           coordinate: .init(latitude: 53.4616212, longitude: -6.2403112)),
        BusStop(id: 580,   name: "Saint Cronan's Sout",                 slug: "saint-cronans-sout",   coordinate: .init(latitude: 53.4598859, longitude: -6.2417255)),
        BusStop(id: 581,   name: "Swords Manor",                         slug: "swords-manor",          coordinate: .init(latitude: 53.459853,  longitude: -6.245138)),
        BusStop(id: 58155, name: "Merrion Square",                       slug: "merrion-square",            coordinate: .init(latitude: 53.339029,  longitude: -6.249886))
    ]
}

// MARK: - Timetable Models & Loader

/// The service day types present in the timetable JSON (source codes are WKD, SAT, SUN)
enum ServiceDay: String, CaseIterable, Codable, Identifiable {
    case weekday = "WKD"
    case saturday = "SAT"
    case sunday = "SUN"
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .weekday: return "Monday–Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }
}

/// A single (stop, time) pair for a trip. `time` is kept as the original HH:mm string (24h) for simple display.
struct TimetableStopTime: Identifiable, Hashable {
    let id = UUID()
    let stop: BusStop
    /// Nil if the trip does not serve this stop (null in JSON)
    let time: String?
}

/// A scheduled trip across ordered stops in one direction.
struct TimetableTrip: Identifiable, Hashable {
    let id: String
    let service: ServiceDay
    let routeID: String
    let direction: RouteDirection
    let stopTimes: [TimetableStopTime]
}

/// Container for all timetable data loaded from `timetable.json` while enforcing BusStop slug consistency.
enum TimetableStore {
    /// Loaded, strongly typed trips. Call `load()` early (e.g. in an `@MainActor` init) before use.
    private(set) static var trips: [TimetableTrip] = []

    /// Quick lookup by trip id after loading.
    private(set) static var tripsByID: [String: TimetableTrip] = [:]

    /// Aggregated stop-based entries when timetable.json uses per-stop schema (direction -> day -> stopSlug -> { name, times:[{route,time}] })
    /// Structure: direction -> serviceDay -> stopSlug -> [TimetableEntry]
    private(set) static var aggregatedStopEntries: [RouteDirection: [ServiceDay: [String: [TimetableEntry]]]] = [:]

    /// Returns trips filtered by parameters.
    static func trips(service: ServiceDay? = nil, direction: RouteDirection? = nil, routeID: String? = nil) -> [TimetableTrip] {
        trips.filter { t in
            (service == nil || t.service == service!) &&
            (direction == nil || t.direction == direction!) &&
            (routeID == nil || t.routeID == routeID!)
        }
    }

    /// Load & parse timetable.json once. Safe to call repeatedly (idempotent).
    static func load(bundle: Bundle = .main, filename: String = "timetable", fileExtension: String = "json") {
        guard trips.isEmpty && aggregatedStopEntries.isEmpty else { return }

        guard let url = bundle.url(forResource: filename, withExtension: fileExtension) else {
            #if DEBUG
            print("[TimetableStore] timetable.json not found in bundle")
            #endif
            return
        }

        do {
            let data = try Data(contentsOf: url)
            // 1. Aggregated per-stop format (preferred new schema)
            if decodeAggregatedFormat(data: data) {
                #if DEBUG
                print("[TimetableStore] Loaded aggregated stop-based timetable format")
                #endif
            }
            // 2. Trip-based new format (stops array + timetable)
            else if let newTrips = try decodeNewFormat(data: data) {
                applyLoadedTrips(newTrips)
            }
            // 3. Legacy GTFS-like flat trips list
            else {
                let legacy = try decodeLegacyFormat(data: data)
                applyLoadedTrips(legacy)
            }
        } catch {
            #if DEBUG
            print("[TimetableStore] Failed to load timetable: \(error)")
            #endif
        }
    }

    /// Apply loaded trips & reset caches.
    private static func applyLoadedTrips(_ loaded: [TimetableTrip]) {
        trips = loaded.sorted { $0.id < $1.id }
        tripsByID = Dictionary(uniqueKeysWithValues: trips.map { ($0.id, $0) })
        entriesCache.removeAll()
        #if DEBUG
        print("[TimetableStore] Loaded \(trips.count) trips")
        #endif
    }

    // MARK: - Decoding (Aggregated Stop Format)
    /// Decode aggregated schema: { "toCity": { "weekday": { "stop-slug": { name:"...", times:[{route,time}] } ... }, "saturday": {...}, ... }, "toSwords": {...} }
    /// Returns true if successfully decoded and populated.
    @discardableResult
    private static func decodeAggregatedFormat(data: Data) -> Bool {
        struct AggregatedRoot: Decodable {
            struct StopTimes: Decodable { let route: String?; let time: String? }
            struct StopBlock: Decodable { let name: String?; let times: [StopTimes]? }
            struct Direction: Decodable {
                let weekday: [String: StopBlock]? // stopSlug -> StopBlock
                let saturday: [String: StopBlock]?
                let sunday: [String: StopBlock]?
            }
            let toCity: Direction?
            let toSwords: Direction?
        }

        let decoder = JSONDecoder()
        guard let root = try? decoder.decode(AggregatedRoot.self, from: data) else { return false }
        if root.toCity == nil && root.toSwords == nil { return false }

        func convert(direction: RouteDirection, dir: AggregatedRoot.Direction?) -> [ServiceDay: [String: [TimetableEntry]]] {
            guard let dir else { return [:] }
            var dayMap: [ServiceDay: [String: [TimetableEntry]]] = [:]
            let tuples: [(ServiceDay, [String: AggregatedRoot.StopBlock]?)] = [(.weekday, dir.weekday), (.saturday, dir.saturday), (.sunday, dir.sunday)]
            for (day, stopsDictOpt) in tuples {
                guard let stopsDict = stopsDictOpt else { continue }
                var stopEntries: [String: [TimetableEntry]] = [:]
                for (slug, block) in stopsDict {
                    let entries = (block.times ?? [])
                        .compactMap { st -> TimetableEntry? in
                            guard let time = st.time, let route = st.route, !time.isEmpty else { return nil }
                            return TimetableEntry(time: time, route: route)
                        }
                        .sorted { timeStringCompare($0.time, $1.time) }
                    if !entries.isEmpty { stopEntries[slug] = entries }
                }
                if !stopEntries.isEmpty { dayMap[day] = stopEntries }
            }
            return dayMap
        }

        var aggregate: [RouteDirection: [ServiceDay: [String: [TimetableEntry]]]] = [:]
        let city = convert(direction: .toCity, dir: root.toCity)
        if !city.isEmpty { aggregate[.toCity] = city }
        let swords = convert(direction: .toSwords, dir: root.toSwords)
        if !swords.isEmpty { aggregate[.toSwords] = swords }
        if aggregate.isEmpty { return false }
        aggregatedStopEntries = aggregate
        return true
    }

    // MARK: - Decoding (Trip-Based New Format)
    /// Attempt to decode the new `toCity` / `toSwords` structured timetable. Returns nil if structure does not match.
    private static func decodeNewFormat(data: Data) throws -> [TimetableTrip]? {
        struct Root: Decodable {
            struct DirectionContainer: Decodable {
                struct Stop: Decodable { let id: Int; let name: String; let slug: String }
                struct DayTrip: Decodable { let times: [StopTime] }
                struct StopTime: Decodable { let stop_code: String?; let time: String?; let seq: Int }
                struct TimetableDays: Decodable { let weekday: [DayTrip]?; let saturday: [DayTrip]?; let sunday: [DayTrip]? }
                let stops: [Stop]
                let timetable: TimetableDays
            }
            let toCity: DirectionContainer?
            let toSwords: DirectionContainer?
        }

        let decoder = JSONDecoder()
        guard let root = try? decoder.decode(Root.self, from: data) else { return nil }

        var result: [TimetableTrip] = []

        func serviceDay(for key: String) -> ServiceDay? {
            switch key.lowercased() {
            case "weekday": return .weekday
            case "saturday": return .saturday
            case "sunday": return .sunday
            default: return nil
            }
        }

        // Helper map for quick lookup of canonical stops with coordinates
        let cityStopsCanonical = Dictionary(uniqueKeysWithValues: StopsData.toCity.map { ($0.slug, $0) })
        let swordsStopsCanonical = Dictionary(uniqueKeysWithValues: StopsData.toSwords.map { ($0.slug, $0) })

        func buildTrips(from container: Root.DirectionContainer?, direction: RouteDirection) {
            guard let container else { return }
            let dayMap: [(String, [Root.DirectionContainer.DayTrip]?)] = [
                ("weekday", container.timetable.weekday),
                ("saturday", container.timetable.saturday),
                ("sunday", container.timetable.sunday)
            ]
            let canonicalLookup = direction == .toCity ? cityStopsCanonical : swordsStopsCanonical
            // Build ordered list of canonical stops based on slug sequence in JSON stops array
            let orderedStops: [BusStop] = container.stops.compactMap { canonicalLookup[$0.slug] }

            for (dayKey, tripsArrayOpt) in dayMap {
                guard let service = serviceDay(for: dayKey), let tripsArray = tripsArrayOpt else { continue }
                for (idx, jsonTrip) in tripsArray.enumerated() {
                    // Build stopTimes by matching seq to orderedStops index.
                    var stopTimes: [TimetableStopTime] = []
                    for (sIndex, stop) in orderedStops.enumerated() {
                        if let st = jsonTrip.times.first(where: { $0.seq == sIndex }) {
                            stopTimes.append(TimetableStopTime(stop: stop, time: st.time))
                        } else {
                            stopTimes.append(TimetableStopTime(stop: stop, time: nil))
                        }
                    }
                    // Infer route ID from any stop_code/time pairs present (fallback to base 500 if absent)
                    let codes = Set(jsonTrip.times.compactMap { $0.stop_code }).filter { !$0.isEmpty }
                    let inferredRoute: String = {
                        if codes.isEmpty { return "500" }
                        let candidates = Array(codes)
                        return TimetableStore.preferredRoute(from: candidates) ?? candidates.sorted().first ?? "500"
                    }()
                    let tripID = "\(direction == .toCity ? "toCity" : "toSwords")-\(service.rawValue)-\(idx)"
                    result.append(TimetableTrip(id: tripID, service: service, routeID: inferredRoute, direction: direction, stopTimes: stopTimes))
                }
            }
        }

        buildTrips(from: root.toCity, direction: .toCity)
        buildTrips(from: root.toSwords, direction: .toSwords)

        return result
    }

    // MARK: - Decoding (Legacy Format)
    private static func decodeLegacyFormat(data: Data) throws -> [TimetableTrip] {
        let decoded = try JSONDecoder().decode(TimetableFile.self, from: data)
        var built: [TimetableTrip] = []
        for trip in decoded.trips {
            guard let service = ServiceDay(rawValue: trip.service_id) else { continue }
            let direction: RouteDirection = trip.direction_id == 0 ? .toCity : .toSwords
            let orderedStops = direction == .toCity ? StopsData.toCity : StopsData.toSwords
            func normalise(_ raw: String) -> String {
                var s = raw.replacingOccurrences(of: "_", with: "-")
                let corrections: [String: String] = [
                    "lios-cian": "lios-cian",
                    "lions-cian": "lions-cian",
                    "saint-cronans-sout": "saint-cronans-sout"
                ]
                if let corrected = corrections[s] { s = corrected }
                return s
            }
            var stopTimes: [TimetableStopTime] = []
            for stop in orderedStops {
                let rawTime = trip.stop_times.first { key, _ in
                    normalise(key) == stop.slug
                }?.value
                stopTimes.append(TimetableStopTime(stop: stop, time: rawTime))
            }
            built.append(TimetableTrip(id: trip.trip_id, service: service, routeID: trip.route_id, direction: direction, stopTimes: stopTimes))
        }
        return built
    }

    // MARK: - Query Helpers

    /// Determine service day code for a given date (local Europe/Dublin calendar).
    static func serviceDay(for date: Date = Date()) -> ServiceDay {
        let cal = Calendar(identifier: .gregorian)
        let weekday = cal.component(.weekday, from: date) // 1 = Sunday, 2 = Monday ... 7 = Saturday
        if weekday == 1 { return .sunday }
        if weekday == 7 { return .saturday }
        return .weekday
    }

    /// All timetable entries (time + route) for a stop & direction for the provided service day.
    static func allEntries(for stop: BusStop, direction: RouteDirection, service: ServiceDay = serviceDay(for: Date())) -> [TimetableEntry] {
        ensureLoaded()
        let cacheKey = cacheKeyFor(stop: stop, direction: direction, service: service)
        if let cached = entriesCache[cacheKey] { return cached }
        // Aggregated path
        if trips.isEmpty, let dirMap = aggregatedStopEntries[direction], let dayMap = dirMap[service], let entries = dayMap[stop.slug] {
            entriesCache[cacheKey] = entries
            return entries
        }
        // Trip-based path
        let relevant = trips.filter { $0.direction == direction && $0.service == service }
        var built: [TimetableEntry] = []
        for trip in relevant {
            if let st = trip.stopTimes.first(where: { $0.stop.slug == stop.slug }), let time = st.time {
                built.append(TimetableEntry(time: time, route: trip.routeID))
            }
        }
        let sorted = built.sorted(by: { timeStringCompare($0.time, $1.time) })
        entriesCache[cacheKey] = sorted
        return sorted
    }

    /// Upcoming timetable entries from now for a stop & direction.
    static func upcomingEntries(for stop: BusStop, direction: RouteDirection, from date: Date = Date(), limit: Int = 5) -> [TimetableEntry] {
        let service = serviceDay(for: date)
        let all = allEntries(for: stop, direction: direction, service: service)
        guard !all.isEmpty else { return [] }
        let filtered = all.filter { isTime($0.time, onOrAfter: date) }
        if filtered.isEmpty { return [] }
        return Array(filtered.prefix(limit))
    }

    /// Convenience: ensure timetable loaded.
    private static func ensureLoaded() { if trips.isEmpty && aggregatedStopEntries.isEmpty { load() } }

    /// Compare two HH:mm strings chronologically.
    private static func timeStringCompare(_ a: String, _ b: String) -> Bool {
        guard let (ah, am) = parseHHMM(a), let (bh, bm) = parseHHMM(b) else { return a < b }
        if ah == bh { return am < bm } else { return ah < bh }
    }

    private static func parseHHMM(_ s: String) -> (Int, Int)? {
        let parts = s.split(separator: ":")
        if parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) { return (h, m) }
        return nil
    }

    private static func isTime(_ time: String, onOrAfter date: Date) -> Bool {
        guard let (h, m) = parseHHMM(time) else { return false }
        let cal = Calendar(identifier: .gregorian)
        var comps = cal.dateComponents([.year, .month, .day], from: date)
        comps.hour = h; comps.minute = m; comps.second = 0
        if let dt = cal.date(from: comps) { return dt >= date } else { return false }
    }

    // MARK: - Caching
    private static var entriesCache: [String: [TimetableEntry]] = [:]
    private static func cacheKeyFor(stop: BusStop, direction: RouteDirection, service: ServiceDay) -> String {
        "\(service.rawValue)|\(direction.rawValue)|\(stop.slug)"
    }

    // MARK: - Route Preference
    /// Prefer Express (X) over Night (N) over base numeric; fallback to lexical.
    static func preferredRoute(from routes: [String]) -> String? {
        guard !routes.isEmpty else { return nil }
        if let express = routes.first(where: { $0.uppercased().hasSuffix("X") }) { return express }
        if let night = routes.first(where: { $0.uppercased().hasSuffix("N") }) { return night }
        // If duplicates like 500 & 500X present, we already handled X path. Otherwise choose lowest numeric prefix then lexical.
        func numericPrefix(_ r: String) -> Int? { Int(r.prefix { $0.isNumber }) }
        return routes.sorted { (a, b) in
            let na = numericPrefix(a) ?? Int.max
            let nb = numericPrefix(b) ?? Int.max
            if na == nb { return a < b } else { return na < nb }
        }.first
    }
}

// MARK: - Raw JSON Decoding Helpers

private struct TimetableFile: Decodable {
    struct Agency: Decodable { let name: String; let valid_from: String? }
    struct Route: Decodable { let route_id: String; let name: String }
    struct Service: Decodable { let service_id: String; let name: String }
    struct Trip: Decodable {
        let trip_id: String
        let service_id: String
        let route_id: String
        let direction_id: Int
        let stop_times: [String: String?]
    }
    let agency: Agency
    let routes: [Route]
    let services: [Service]
    let trips: [Trip]
}


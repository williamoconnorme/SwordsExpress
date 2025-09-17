//
//  LiveDepartures.swift
//  LiveDepartures
//
//  Created by William O'Connor on 17/09/2025.
//

import WidgetKit
import SwiftUI
import Foundation

// MARK: - Local copies of minimal models & constants (so the widget does not rely on linking the app target)
// NOTE: These must stay in sync with the main app's identifiers. If you add/change stops in the app, mirror them here.
private enum SharedConstants {
    static let appGroupIdentifier = "group.me.williamoconnor.SwordsExpress"
    static let favouriteStopIDsKey = "favouriteStopIDs"
    static let favouriteStopOrderKey = "favouritesOrder"
}

private struct BusStop: Identifiable, Hashable {
    let id: Int
    let name: String
    let slug: String
}

private enum StopsData {
    static let toCity: [BusStop] = [
        BusStop(id: 333,  name: "Abbeyvale",                slug: "abbeyvale"),
        BusStop(id: 334,  name: "Swords Manor",             slug: "swords-manor"),
        BusStop(id: 339,  name: "Valley View",              slug: "valley-view"),
        BusStop(id: 338,  name: "The Gallops",              slug: "the-gallops"),
        BusStop(id: 337,  name: "Lios Cian",                slug: "lions-cian"),
        BusStop(id: 336,  name: "Cianlea",                  slug: "cianlea"),
        BusStop(id: 1234, name: "Laurelton",                slug: "laurelton"),
        BusStop(id: 340,  name: "Applewood Estate",         slug: "applewood-estate"),
        BusStop(id: 341,  name: "Jugback Lane",             slug: "jugback-lane"),
        BusStop(id: 342,  name: "Saint Colmcille's GFC",    slug: "saint-colmcilles-gfc"),
        BusStop(id: 343,  name: "West Seatown",             slug: "west-seatown"),
        BusStop(id: 344,  name: "Seatown Road",             slug: "seatown-road"),
        BusStop(id: 345,  name: "Swords Bypass",            slug: "swords-bypass"),
        BusStop(id: 582,  name: "Malahide Roundabout",      slug: "malahide-roundabout"),
        BusStop(id: 347,  name: "Pavilions Shopping Centre",slug: "pavilions-shopping-centre"),
        BusStop(id: 348,  name: "Dublin Road (Penneys)",    slug: "dublin-road-penneys"),
        BusStop(id: 583,  name: "Highfields",               slug: "highfields"),
        BusStop(id: 587,  name: "Ballintrane",              slug: "ballintrane"),
        BusStop(id: 351,  name: "Boroimhe Laurels",         slug: "boroimhe-laurels"),
        BusStop(id: 352,  name: "Boroimhe Maples",          slug: "boroimhe-maples"),
        BusStop(id: 353,  name: "Airside Road",             slug: "airside-road"),
        BusStop(id: 354,  name: "Airside Central",          slug: "airside-central"),
        BusStop(id: 355,  name: "Holywell Distributor Road",slug: "holywell-distributor-road"),
        BusStop(id: 356,  name: "M1 Drinan",                slug: "m1-drinan"),
        BusStop(id: 357,  name: "East Wall Road",           slug: "east-wall-road"),
        BusStop(id: 584,  name: "Convention Centre",        slug: "convention-centre"),
        BusStop(id: 585,  name: "Seán O'Casey Bridge",      slug: "sean-o-casey-pedestrian-bridge"),
        BusStop(id: 586,  name: "Eden Quay",                slug: "eden-quay")
    ]

    static let toSwords: [BusStop] = [
        BusStop(id: 555,   name: "Eden Quay",                            slug: "eden-quay"),
        BusStop(id: 556,   name: "IFSC",                                 slug: "ifsc"),
        BusStop(id: 557,   name: "Custom House Quay (Jury's)",           slug: "custom-house-quay-jurys"),
        BusStop(id: 558,   name: "Custom House Quay (Clarion)",          slug: "custom-house-quay-clarion"),
        BusStop(id: 559,   name: "North Wall Quay",                      slug: "north-wall-quay"),
        BusStop(id: 560,   name: "Point Depot (North Wall Quay)",        slug: "point-depot-north-wall-quay"),
        BusStop(id: 562,   name: "Holywell Distributor Road",            slug: "holywell-distributor-road"),
        BusStop(id: 563,   name: "Airside Central",                      slug: "airside-central"),
        BusStop(id: 564,   name: "Boroimhe Maples",                      slug: "boroimhe-maples"),
        BusStop(id: 565,   name: "Boroimhe Laurels",                     slug: "boroimhe-laurels"),
        BusStop(id: 566,   name: "Ballintrane",                          slug: "ballintrane"),
        BusStop(id: 567,   name: "Highfields",                           slug: "highfields"),
        BusStop(id: 568,   name: "Dublin Road (opp Penneys)",            slug: "dublin-road-opp-penneys"),
        BusStop(id: 569,   name: "Malahide Roundabout",                  slug: "malahide-roundabout"),
        BusStop(id: 570,   name: "Seatown Road",                         slug: "seatown-road"),
        BusStop(id: 571,   name: "West Seatown",                         slug: "west-seatown"),
        BusStop(id: 572,   name: "Saint Colmcille's GFC",                slug: "saint-colmcilles-gfc"),
        BusStop(id: 573,   name: "Jugback Lane",                         slug: "jugback-lane"),
        BusStop(id: 574,   name: "Applewood Estate",                     slug: "applewood-estate"),
        BusStop(id: 575,   name: "Laurelton",                            slug: "laurelton"),
        BusStop(id: 576,   name: "Cianlea",                               slug: "cianlea"),
        BusStop(id: 577,   name: "Ardcian",                               slug: "ardcian"),
        BusStop(id: 578,   name: "Lios Cian",                             slug: "lios-cian"),
        BusStop(id: 579,   name: "Valley View",                          slug: "valley-view"),
        BusStop(id: 580,   name: "Saint Cronan's Sout",                 slug: "saint-cronans-sout"),
        BusStop(id: 581,   name: "Swords Manor",                         slug: "swords-manor"),
        BusStop(id: 58155, name: "Merrion Square",                       slug: "merrion-square")
    ]
}

@inline(__always)
private func fetchNextBusTimes(direction: String, stop: String) async -> [String] {
    let urlString = "https://www.swordsexpress.com/api/nextBus/?direction=\(direction)&stop=\(stop)"
    guard let url = URL(string: urlString) else { return [] }
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let arr = try JSONSerialization.jsonObject(with: data) as? [String] { return arr }
        if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any], let times = dict["times"] as? [String] { return times }
        return []
    } catch { return [] }
}

// MARK: - Time Utilities
private func parseHHMM(_ original: String) -> Date? {
    // Accept variants like "HH:mm", "HH.mm", possible surrounding whitespace.
    let trimmed = original.trimmingCharacters(in: .whitespacesAndNewlines)
    let canonical = trimmed.replacingOccurrences(of: ".", with: ":")
    let parts = canonical.split(separator: ":")
    guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = .current
    let now = Date()
    var comps = cal.dateComponents([.year, .month, .day], from: now)
    comps.hour = h; comps.minute = m; comps.second = 0
    return cal.date(from: comps)
}

private func filterUpcoming(times: [String], from reference: Date) -> [String] {
    times.compactMap { raw in
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dt = parseHHMM(t) else { return nil }
        return dt >= reference ? t : nil
    }
}

// Enhanced variant for debug: returns upcoming plus arrays of removed past and unparsable values.
private func filterUpcomingWithDiagnostics(times: [String], reference: Date) -> (upcoming: [String], removedPast: [String], unparsable: [String]) {
    var upcoming: [String] = []
    var removedPast: [String] = []
    var unparsable: [String] = []
    for raw in times {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let dt = parseHHMM(t) else { unparsable.append(t); continue }
        if dt >= reference { upcoming.append(t) } else { removedPast.append(t) }
    }
    return (upcoming, removedPast, unparsable)
}

private func sortChronologically(_ times: [String]) -> [String] {
    return times.sorted { a, b in
        let ta = a.trimmingCharacters(in: .whitespacesAndNewlines)
        let tb = b.trimmingCharacters(in: .whitespacesAndNewlines)
        if let da = parseHHMM(ta), let db = parseHHMM(tb) { return da < db }
        // Fallback deterministic lexical compare after trimming
        return ta < tb
    }
}

// Countdown formatting removed – widget now shows absolute times only and reloads at each departure.

private func sampleFutureTimes(offsetMins: [Int], from reference: Date) -> [String] {
    let cal = Calendar(identifier: .gregorian)
    return offsetMins.compactMap { off -> String? in
        if let dt = cal.date(byAdding: .minute, value: off, to: reference) {
            let comps = cal.dateComponents([.hour, .minute], from: dt)
            if let h = comps.hour, let m = comps.minute { return String(format: "%02d:%02d", h, m) }
        }
        return nil
    }
}

// MARK: - Live Departures Data Model for Widget
struct StopLiveDepartures: Identifiable, Hashable {
    let id: Int
    let name: String
    let direction: String // "To City" / "To Swords"
    let times: [String] // Raw HH:mm strings (upcoming trimmed)
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), stops: sampleStops())
    }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: Date(), stops: sampleStops()))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let generationTime = Date()
            let entry = await makeEntry(referenceDate: generationTime)
            // Find earliest future departure across all stops
            let allFuture: [Date] = entry.stops.flatMap { stop in
                stop.times.compactMap { parseHHMM($0) }.filter { $0 > generationTime }
            }.sorted()
            // Choose next reload: shortly after the earliest departure OR fallback in 5 minutes if none.
            let earliest = allFuture.first
            let reloadDate = earliest?.addingTimeInterval(5) ?? generationTime.addingTimeInterval(5 * 60)
            let df = DateFormatter(); df.dateFormat = "HH:mm:ss"
            let futureSample = allFuture.prefix(10).map { df.string(from: $0) }.joined(separator: ",")
            print("[LiveDeparturesWidget] Timeline gen=\(df.string(from: generationTime)) earliestDep=\(earliest.map{df.string(from:$0)} ?? "none") reload=\(df.string(from: reloadDate)) future=[\(futureSample)]")
            completion(Timeline(entries: [entry], policy: .after(reloadDate)))
        }
    }

    private func makeEntry(referenceDate: Date = Date()) async -> SimpleEntry {
        let favourites = loadFavouriteStops()
        // If none favourited produce placeholder style entry
        if favourites.isEmpty {
            return SimpleEntry(date: referenceDate, stops: [])
        }
        let stopsToDisplay = favourites
        var live: [StopLiveDepartures] = []
        let now = referenceDate
        await withTaskGroup(of: StopLiveDepartures?.self) { group in
            for stop in stopsToDisplay {
                group.addTask {
                    let directionParam: String = {
                        if StopsData.toCity.contains(stop) { return "swords_to_city" } else { return "city_to_swords" }
                    }()
                    let times = await fetchNextBusTimes(direction: directionParam, stop: stop.slug)
                    let diag = filterUpcomingWithDiagnostics(times: times, reference: now)
                    let upcoming = sortChronologically(diag.upcoming) // Keep only future & sort ascending
#if DEBUG
                    if !times.isEmpty {
                        let rawSample = times.joined(separator: ",")
                        let upcomingSample = upcoming.joined(separator: ",")
                        let removedPast = diag.removedPast.joined(separator: ",")
                        let unparsable = diag.unparsable.joined(separator: ",")
                        print("[LiveDeparturesWidget] Stop=\(stop.slug) RAW=[\(rawSample)] UPCOMING=[\(upcomingSample)] REMOVED_PAST=[\(removedPast)] UNPARSABLE=[\(unparsable)] ref=\(now)")
                    }
#endif
                    let dirLabel = StopsData.toCity.contains(stop) ? "To City" : "To Swords"
                    return StopLiveDepartures(id: stop.id, name: stop.name, direction: dirLabel, times: upcoming)
                }
            }
            for await result in group { if let result { live.append(result) } }
        }
        // Apply explicit stored ordering if available, else name sort
        if let defaults = UserDefaults(suiteName: SharedConstants.appGroupIdentifier),
           let orderRaw = defaults.string(forKey: SharedConstants.favouriteStopOrderKey), !orderRaw.isEmpty {
            let orderIDs = orderRaw.split(separator: ",").compactMap { Int($0) }
            let indexMap = Dictionary(uniqueKeysWithValues: orderIDs.enumerated().map { ($1, $0) })
            live.sort { (a, b) in
                let ia = indexMap[a.id] ?? Int.max
                let ib = indexMap[b.id] ?? Int.max
                if ia == ib { return a.name < b.name }
                return ia < ib
            }
        } else {
            live.sort { $0.name < $1.name }
        }
        return SimpleEntry(date: Date(), stops: live)
    }

    // nextDeparture removed – using multi-entry timeline schedule instead.

    // MARK: - Helpers
    private func loadFavouriteStops() -> [BusStop] {
        let suiteDefaults = UserDefaults(suiteName: SharedConstants.appGroupIdentifier)
        let suiteIDs = (suiteDefaults?.array(forKey: SharedConstants.favouriteStopIDsKey) as? [Int]) ?? []
        var ids = suiteIDs
        if ids.isEmpty {
            let standardIDs = (UserDefaults.standard.array(forKey: SharedConstants.favouriteStopIDsKey) as? [Int]) ?? []
            if !standardIDs.isEmpty { ids = standardIDs }
#if DEBUG
            if suiteDefaults == nil {
                print("[LiveDeparturesWidget] App Group defaults nil – check App Group entitlement")
            } else {
                print("[LiveDeparturesWidget] No favourites in app group; standard defaults count=\(standardIDs.count)")
            }
#endif
        }
        if ids.isEmpty { return [] }
        let all = StopsData.toCity + StopsData.toSwords
        let dict = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        return ids.compactMap { dict[$0] }
    }

    private func sampleStops() -> [StopLiveDepartures] {
        let now = Date()
        let a = sampleFutureTimes(offsetMins: [5, 25, 55], from: now)
        let b = sampleFutureTimes(offsetMins: [8, 28, 58], from: now)
        return [
            StopLiveDepartures(id: 333, name: "Abbeyvale", direction: "To City", times: a),
            StopLiveDepartures(id: 586, name: "Eden Quay", direction: "To Swords", times: b)
        ]
    }
}

struct SimpleEntry: TimelineEntry { let date: Date; let stops: [StopLiveDepartures] }

struct LiveDeparturesEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium, .systemLarge, .systemExtraLarge:
            listView(maxStops: family == .systemMedium ? 3 : 6)
        default:
            listView(maxStops: 4)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Swords Express")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("No favourites yet")
                .font(.headline)
            Text("Add stops in the app to see live times here.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.vertical, 8)
    }

    private var smallView: some View {
        Group {
            if let first = entry.stops.first {
                VStack(alignment: .leading, spacing: 4) {
                    Text(first.name)
                        .font(.footnote.weight(.semibold))
                        .lineLimit(2)
                    timesRow(times: first.times)
                    lastUpdatedView
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                emptyState
            }
        }
        .padding(10)
    }

    private func listView(maxStops: Int) -> some View {
        let stops = Array(entry.stops.prefix(maxStops))
        return VStack(alignment: .leading, spacing: 6) {
            if stops.isEmpty { emptyState } else {
                ForEach(stops) { stop in
                    VStack(alignment: .leading, spacing: 2) {
                        header(stopName: stop.name, direction: stop.direction)
                        timesRow(times: stop.times)
                    }
                    if stop.id != stops.last?.id { Divider().opacity(0.25) }
                }
                Spacer(minLength: 0)
                lastUpdatedView
            }
        }
        .padding(10)
    }

    private func header(stopName: String, direction: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(stopName)
                .font(.footnote.weight(.semibold))
                .lineLimit(1)
            Spacer(minLength: 2)
            Text(direction)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private func timesRow(times: [String]) -> some View {
        HStack(spacing: 6) {
            if times.isEmpty {
                Text("—")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            } else {
                // Display only the first three upcoming times for compactness
                ForEach(Array(times.prefix(3)), id: \.self) { time in
                    Text(time)
                        .font(.caption.monospacedDigit())
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.accentColor.opacity(0.15)))
                        .accessibilityLabel("Departure at \(time)")
                }
            }
        }
    }

    private var lastUpdatedView: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("Last Updated \(entry.date.formatted(date: .omitted, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .accessibilityLabel("Last updated at \(entry.date.formatted(date: .omitted, time: .shortened))")
    }
}

struct LiveDepartures: Widget {
    let kind: String = "LiveDepartures"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LiveDeparturesEntryView(entry: entry)
                .containerBackground(.thinMaterial, for: .widget)
        }
        .configurationDisplayName("Live Departures")
        .description("Shows next bus times for your favourite stops.")
        // Reload policy is event-driven (next departure) via timeline provider.
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews
#Preview(as: .systemMedium) {
    LiveDepartures()
} timeline: {
    SimpleEntry(date: Date(), stops: [
        StopLiveDepartures(id: 333, name: "Abbeyvale", direction: "To City", times: ["12:05", "12:25", "12:55"]),
        StopLiveDepartures(id: 586, name: "Eden Quay", direction: "To Swords", times: ["12:08", "12:28", "12:58"])
    ])
}


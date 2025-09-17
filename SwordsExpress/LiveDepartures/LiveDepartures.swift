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
private func parseHHMM(_ s: String) -> Date? {
    let parts = s.split(separator: ":")
    guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = .current
    let now = Date()
    var comps = cal.dateComponents([.year, .month, .day], from: now)
    comps.hour = h; comps.minute = m; comps.second = 0
    return cal.date(from: comps)
}

private func filterUpcoming(times: [String], from reference: Date) -> [String] {
    times.compactMap { t in
        guard let dt = parseHHMM(t) else { return nil }
        return dt >= reference ? t : nil
    }
}

private func countdownString(for time: String, from reference: Date) -> String {
    guard let dt = parseHHMM(time) else { return "" }
    let diff = Int(dt.timeIntervalSince(reference) / 60)
    if diff <= 0 { return "Due" }
    if diff < 60 { return "\(diff)m" }
    let hours = diff / 60
    let mins = diff % 60
    return mins == 0 ? "\(hours)h" : "\(hours)h\(mins)m"
}

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
    let times: [String] // Raw HH:mm strings
    let countdowns: [String] // Relative mins e.g. ["5m", "12m", "Due"]
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
            let entry = await makeEntry()
            let next = Date().addingTimeInterval(60)
            completion(Timeline(entries: [entry], policy: .after(next)))
        }
    }

    private func makeEntry() async -> SimpleEntry {
        let favourites = loadFavouriteStops()
        // If none favourited produce placeholder style entry
        if favourites.isEmpty {
            return SimpleEntry(date: Date(), stops: [])
        }
        let stopsToDisplay = favourites
        // Fetch in parallel, but limit concurrency to be respectful (WidgetKit background)
        var live: [StopLiveDepartures] = []
        let now = Date()
        await withTaskGroup(of: StopLiveDepartures?.self) { group in
            for stop in stopsToDisplay {
                group.addTask {
                    let directionParam: String = {
                        // If the stop appears in toCity list => user is travelling to City, API direction param is swords_to_city
                        if StopsData.toCity.contains(stop) { return "swords_to_city" } else { return "city_to_swords" }
                    }()
                    let times = await fetchNextBusTimes(direction: directionParam, stop: stop.slug)
                    let upcoming = filterUpcoming(times: times, from: now)
                    let trimmed = Array(upcoming.prefix(3))
                    let countdowns = trimmed.map { countdownString(for: $0, from: now) }
                    let dirLabel = StopsData.toCity.contains(stop) ? "To City" : "To Swords"
                    return StopLiveDepartures(id: stop.id, name: stop.name, direction: dirLabel, times: trimmed, countdowns: countdowns)
                }
            }
            for await result in group { if let result { live.append(result) } }
        }
        // Sort by stop name for deterministic display
        live.sort { $0.name < $1.name }
        return SimpleEntry(date: Date(), stops: live)
    }

    // MARK: - Helpers
    private func loadFavouriteStops() -> [BusStop] {
        let suiteDefaults = UserDefaults(suiteName: SharedConstants.appGroupIdentifier)
        let suiteIDs = (suiteDefaults?.array(forKey: SharedConstants.favouriteStopIDsKey) as? [Int]) ?? []
        var ids = suiteIDs
        // Fallback: if the app group isn't yielding anything, try standard defaults (common sign that the App Group capability isn't enabled for the widget target yet)
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
        // Combine all static stops provided by the main app's StopsData
        let all = StopsData.toCity + StopsData.toSwords
        let dict = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        return ids.compactMap { dict[$0] }
    }

    private func sampleStops() -> [StopLiveDepartures] {
        let now = Date()
        let a = sampleFutureTimes(offsetMins: [5, 25, 55], from: now)
        let b = sampleFutureTimes(offsetMins: [8, 28, 58], from: now)
        return [
            StopLiveDepartures(id: 333, name: "Abbeyvale", direction: "To City", times: a, countdowns: a.map { countdownString(for: $0, from: now) }),
            StopLiveDepartures(id: 586, name: "Eden Quay", direction: "To Swords", times: b, countdowns: b.map { countdownString(for: $0, from: now) })
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
                    header(stopName: first.name, direction: first.direction)
                    timesRow(times: first.times, countdowns: first.countdowns)
                    Spacer(minLength: 0)
                    footerTimestamp
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
                        timesRow(times: stop.times, countdowns: stop.countdowns)
                    }
                    if stop.id != stops.last?.id { Divider().opacity(0.25) }
                }
                Spacer(minLength: 0)
                footerTimestamp
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

    private func timesRow(times: [String], countdowns: [String]) -> some View {
        HStack(spacing: 6) {
            if times.isEmpty {
                Text("—")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(zip(times, countdowns)), id: \.0) { time, rel in
                    Text(rel)
                        .font(.caption.monospacedDigit())
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.accentColor.opacity(0.15)))
                        .accessibilityLabel("\(time) in \(rel == "Due" ? "0" : rel.replacingOccurrences(of: "m", with: "")) minutes")
                }
            }
        }
    }

    private var footerTimestamp: some View {
        HStack {
            Text(Date(), style: .time)
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.secondary)
            Spacer()
            Image(systemName: "bus")
                .font(.caption)
        }
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
        // Frequent refreshes requested via timeline (every minute) – WidgetKit may coalesce.
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews
#Preview(as: .systemMedium) {
    LiveDepartures()
} timeline: {
    SimpleEntry(date: Date(), stops: [
        StopLiveDepartures(id: 333, name: "Abbeyvale", direction: "To City", times: ["12:05", "12:25", "12:55"], countdowns: ["5m", "25m", "55m"]),
        StopLiveDepartures(id: 586, name: "Eden Quay", direction: "To Swords", times: ["12:08", "12:28", "12:58"], countdowns: ["8m", "28m", "58m"])
    ])
}


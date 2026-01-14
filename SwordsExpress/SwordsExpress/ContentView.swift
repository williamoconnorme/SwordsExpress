//  ContentView.swift
//  SwordsExpress
//
//  Created by William O'Connor on 11/09/2025.
//

import SwiftUI
import SwiftData
import MapKit
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

// MARK: - Supporting UI Utilities & Extensions
// Provide color tokens used throughout the views.
extension Color {
    // Primary brand accent (restored to green as per original design intent)
    static let brandPrimary: Color = .green
    // Secondary highlight (kept as pink for stop emphasis)
    static let stopPink: Color = .pink
}

// Preference key for capturing control panel width.
private struct ControlPanelWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// Lightweight Map content placeholders (can be replaced with richer rendering later).
@available(iOS 17.0, *)
private struct RoutePolylineView: MapContent {
    let coordinates: [CLLocationCoordinate2D]
    var body: some MapContent {
        if coordinates.count > 1 {
            MapPolyline(coordinates: coordinates)
                .stroke(Color.brandPrimary, lineWidth: 3)
        }
    }
}

@available(iOS 17.0, *)
private struct BusAnnotationsContent: MapContent {
    let buses: [Bus]
    let selectedBus: Bus?
    let onTap: (Bus) -> Void
    var body: some MapContent {
        ForEach(buses) { bus in
            let isSelected = bus.id == selectedBus?.id
            Annotation("", coordinate: bus.coordinate) {
                ZStack {
                    Circle()
                        .fill(Color.brandPrimary.opacity(isSelected ? 0.95 : 0.75))
                        .frame(width: isSelected ? 34 : 26, height: isSelected ? 34 : 26)
                        .shadow(color: .black.opacity(0.25), radius: isSelected ? 6 : 3, y: 2)
                    Image(systemName: "bus.fill")
                        .font(.system(size: isSelected ? 16 : 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(0))
                }
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .animation(.spring(response: 0.45, dampingFraction: 0.78), value: isSelected)
                .onTapGesture { onTap(bus) }
                .accessibilityLabel("Bus \(bus.id)")
            }
        }
    }
}

@available(iOS 17.0, *)
private struct StopAnnotationsContent: MapContent {
    let stops: [BusStop]
    let selectedStop: BusStop?
    let onTap: (BusStop) -> Void
    let disappearingIDs: Set<BusStop.ID>
    var body: some MapContent {
        ForEach(stops) { stop in
            let isSelected = stop.id == selectedStop?.id
            let isDisappearing = disappearingIDs.contains(stop.id)
            Annotation(stop.name, coordinate: stop.coordinate) {
                ZStack {
                    Circle()
                        .fill(Color.stopPink.opacity(isSelected ? 0.92 : 0.55))
                        .frame(width: isSelected ? 30 : 20, height: isSelected ? 30 : 20)
                        .overlay(
                            Circle().stroke(Color.white.opacity(isSelected ? 0.9 : 0.0), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(isSelected ? 0.3 : 0.15), radius: isSelected ? 6 : 3, y: 2)
                    if isSelected {
                        Image(systemName: "mappin")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .offset(y: -1)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .scaleEffect(isDisappearing ? 0.3 : (isSelected ? 1.15 : 1.0))
                .opacity(isDisappearing ? 0.0 : 1.0)
                .animation(.easeInOut(duration: 0.25), value: isDisappearing)
                .animation(.spring(response: 0.45, dampingFraction: 0.82), value: isSelected)
                .onTapGesture { onTap(stop) }
                .accessibilityLabel("Stop: \(stop.name)")
            }
        }
    }
}

// MARK: - StopTimetableView (clean implementation)
struct StopTimetableView: View {
    let direction: RouteDirection
    let stop: BusStop
    // Timetable state
    @State private var times: [TimetableEntry] = []
    @State private var isLoadingTimetable = true
    @State private var errorMessage: String? = nil
    @State private var usedLocalTimetable = false
    @State private var selectedServiceDay: ServiceDay = TimetableStore.serviceDay()

    init(direction: RouteDirection, stop: BusStop) {
        self.direction = direction
        self.stop = stop
    }

    // Live (NextBus) integration
    @State private var liveTimes: [String] = []                    // Raw HH:mm strings from API
    @State private var isLoadingLive: Bool = true
    @State private var liveRouteMatches: [String: String] = [:]    // live HH:mm -> route ID (inferred)
    @State private var liveFetchError: String? = nil

    // Relative interval updating
    @State private var now: Date = Date()
    @State private var lastRenderedMinute: Int = Calendar.current.component(.minute, from: Date())
    private var minuteTimer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    // (Removed separate nextEntry section – live data + full timetable cover use case)

    @EnvironmentObject private var favourites: FavouritesStore
    private var isFavourite: Bool { favourites.isFavourite(stop) }

    var body: some View {
        List {
            // Live (NextBus) Section
            Section("Live Departures") {
                if isLoadingLive {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Loading live departures…")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if let liveFetchError {
                    Text(liveFetchError).font(.footnote).foregroundStyle(.secondary)
                } else if liveUpcoming().isEmpty {
                    Text("No live times currently available")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    // Convert slice to Array to satisfy ForEach and rely on Identifiable conformance of BusUpcomingTime
                    ForEach(Array(liveUpcoming().prefix(8))) { item in
                        HStack(spacing: 12) {
                            Text(item.time)
                                .font(.body.monospacedDigit())
                            // Countdown moved immediately after the time
                            Text("(\(item.intervalDescription))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if let route = liveRouteMatches[item.time] {
                                Text("Route \(route)")
                                    .font(.caption.weight(.semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.brandPrimary.opacity(0.18)))
                                    .foregroundStyle(Color.brandPrimary)
                            }
                        }
                        .padding(.vertical, 2)
                        .accessibilityLabel("Live departure at \(item.time) \(item.intervalDescription)")
                    }
                }
            }
            Section {
                if isLoadingTimetable {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error).foregroundStyle(.secondary)
                } else if times.isEmpty {
                    Text("No times available.").foregroundStyle(.secondary)
                } else {
                    ForEach(times) { entry in
                        HStack {
                            Text(entry.time)
                                .font(.body.monospacedDigit())
                            Spacer()
                            Text("Route \(entry.route)")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.brandPrimary.opacity(0.18)))
                                .foregroundStyle(Color.brandPrimary)
                        }
                        .accessibilityLabel("Time \(entry.time), Route \(entry.route)")
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(stop.name) Timetable")
                        .font(.headline)
                    HStack(spacing: 8) {
                        Text(direction == .toCity ? "To City" : "To Swords")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Spacer(minLength: 0)
                    }
                    Picker("Service Day", selection: $selectedServiceDay) {
                        ForEach(ServiceDay.allCases) { day in
                            Text(day.displayName.replacingOccurrences(of: "Monday–Friday", with: "Weekday"))
                                .tag(day)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(stop.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { favourites.toggle(stop) }) {
                    Image(systemName: isFavourite ? "heart.fill" : "heart")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(isFavourite ? Color.red : Color.brandPrimary)
                }
                .accessibilityLabel(isFavourite ? "Remove favourite" : "Add favourite")
            }
        }
        .task { await initialLoad() }
        .onReceive(minuteTimer) { date in
            let minute = Calendar.current.component(.minute, from: date)
            if minute != lastRenderedMinute { lastRenderedMinute = minute; now = date }
        }
        .refreshable { await refreshAll() }
        .onChange(of: selectedServiceDay) { _, newValue in
            Task { await loadTimetable(for: newValue) }
        }
    }

    private func loadTimetable(for serviceDay: ServiceDay? = nil) async {
        await MainActor.run { isLoadingTimetable = true; errorMessage = nil }
        do {
            let service = serviceDay ?? selectedServiceDay
            let local = TimetableStore.allEntries(for: stop, direction: direction, service: service)
            if !local.isEmpty {
                await MainActor.run {
                    times = local
                    isLoadingTimetable = false
                    usedLocalTimetable = true
                    inferRoutesForLiveTimes() // we can attempt matching immediately if live already loaded
                }
                return
            }
            // Only attempt remote fallback if user is viewing today's service day (others won't have an API distinction)
            if service == TimetableStore.serviceDay() {
                let directionString = direction == .toSwords ? "city_to_swords" : "swords_to_city"
                let stopParam = stop.slug
                let entries = try await fetchTimetable(direction: directionString, stop: stopParam)
                await MainActor.run {
                    times = entries
                    isLoadingTimetable = false
                    usedLocalTimetable = false
                    inferRoutesForLiveTimes()
                }
            } else {
                await MainActor.run {
                    times = []
                    isLoadingTimetable = false
                    usedLocalTimetable = false
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "No timetable available right now."
                isLoadingTimetable = false
            }
        }
    }

    private func loadLiveTimes() async {
        await MainActor.run { isLoadingLive = true; liveFetchError = nil }
        let directionString = direction == .toSwords ? "city_to_swords" : "swords_to_city"
        do {
            let fetched = try await fetchNextBusTimes(direction: directionString, stop: stop.slug)
            let sorted = fetched.sorted()
            await MainActor.run {
                liveTimes = sorted
                isLoadingLive = false
                inferRoutesForLiveTimes()
            }
        } catch {
            await MainActor.run {
                liveTimes = []
                isLoadingLive = false
                liveFetchError = "Failed to load live data"
            }
        }
    }

    private func inferRoutesForLiveTimes() {
        // Always map live times against the ACTUAL service day (today), not the user-selected picker day.
        guard !liveTimes.isEmpty else { return }
        let actualService = TimetableStore.serviceDay(for: Date())
        // Determine direction context consistently with other loaders
        let direction: RouteDirection = StopsData.toCity.contains(stop) ? .toCity : .toSwords
        let scheduleForMapping = TimetableStore.allEntries(for: stop, direction: direction, service: actualService)
        guard !scheduleForMapping.isEmpty else { return }
        // Build schedule index from actual-service entries
        var byTime: [String: [String]] = [:]
        for entry in scheduleForMapping { byTime[entry.time, default: []].append(entry.route) }
        var mapping: [String: String] = [:]

        func parse(_ t: String) -> (Int, Int)? {
            let parts = t.split(separator: ":"); if parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) { return (h, m) } else { return nil }
        }

        for live in liveTimes {
            if let scheduledRoutes = byTime[live], let chosen = TimetableStore.preferredRoute(from: scheduledRoutes) {
                mapping[live] = chosen
                continue
            }
            // Fuzzy +/- 1 minute
            if let (h, m) = parse(live) {
                let candidates = [m - 1, m + 1].compactMap { mm -> String? in
                    if mm < 0 || mm > 59 { return nil }
                    return String(format: "%02d:%02d", h, mm)
                }
                for cand in candidates {
                    if let scheduledRoutes = byTime[cand], let chosen = TimetableStore.preferredRoute(from: scheduledRoutes) {
                        mapping[live] = chosen
                        break
                    }
                }
            }
        }
        // Only update if we found at least one mapping; retain previous mappings otherwise so they don't "disappear" when user switches days.
        if !mapping.isEmpty { liveRouteMatches = mapping }
    }

    private func liveUpcoming() -> [BusUpcomingTime] {
        BusTimeFormatter.upcomingTimes(from: liveTimes, now: now)
    }

    private func initialLoad() async {
        let today = TimetableStore.serviceDay()
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await loadTimetable(for: today) }
            group.addTask { await loadLiveTimes() }
        }
    }

    private func refreshAll() async {
        await withTaskGroup(of: Void.self) { group in
            let currentSelection = selectedServiceDay
            group.addTask { await loadTimetable(for: currentSelection) }
            group.addTask { await loadLiveTimes() }
        }
    }
}

// (fetchNextBusTimes moved to Networking.swift)

// (FavouritesStore removed here; uses FavouritesStore.swift implementation)

// (FavouriteStopsView moved below timetable-related views for clarity)

// MARK: - NextBusTimesView
struct NextBusTimesView: View {
    let stopName: String
    let times: [String]
    @State private var now: Date = Date()
    private var upcoming: [BusUpcomingTime] { BusTimeFormatter.upcomingTimes(from: times, now: now) }
    // Sub-minute smoothing: tick every 15s, but only trigger UI when minute boundary changes
    @State private var lastRenderedMinute: Int = Calendar.current.component(.minute, from: Date())
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next buses for \(stopName)")
                .font(.headline)
            if upcoming.isEmpty {
                Text("No upcoming buses.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(upcoming) { item in
                    HStack {
                        Text(item.time)
                            .font(.title3)
                        Text("(\(item.intervalDescription))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
        .onReceive(timer) { newDate in
            let minute = Calendar.current.component(.minute, from: newDate)
            if minute != lastRenderedMinute {
                lastRenderedMinute = minute
                now = newDate
            }
        }
        .onAppear {
            now = Date()
            lastRenderedMinute = Calendar.current.component(.minute, from: now)
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var favourites = FavouritesStore()
    @AppStorage("showFavouritesTab") private var showFavouritesTab: Bool = true
    @State private var liveNavPath: [BusStop] = []
    @Environment(\.openFavouritesFromWidget) private var openFavouritesFromWidget: Bool
    @State private var selectedTab: Int = 0 // 0=Live,1=Timetable,2=Favourites (if present),3=Information

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $liveNavPath) {
                LiveView(onOpenTimetable: { stop in
                    liveNavPath.append(stop)
                })
                .navigationDestination(for: BusStop.self) { stop in
                    let direction: RouteDirection = StopsData.toCity.contains(stop) ? .toCity : .toSwords
                    StopTimetableView(direction: direction, stop: stop)
                }
            }
            .tabItem { Label("Live", systemImage: "dot.radiowaves.left.and.right") }
            .tag(0)
            
            ScheduleView()
                .tabItem { Label("Timetable", systemImage: "calendar") }
                .tag(1)
            
            if showFavouritesTab && !favourites.favouriteStops.isEmpty {
                NavigationStack {
                    FavouriteStopsView()
                        .navigationTitle("Favourites")
                }
                .tabItem { Label("Favourites", systemImage: "heart.fill") }
                .tag(2)
            }
            
            NavigationStack {
                InformationView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink {
                                SettingsView(showFavouritesTab: $showFavouritesTab)
                            } label: { Image(systemName: "gear") }
                            .accessibilityLabel("Settings")
                        }
                    }
                    .navigationTitle("Information")
            }
            .tabItem { Label("Information", systemImage: "info.circle") }
            .tag( showFavouritesTab && !favourites.favouriteStops.isEmpty ? 3 : 2 )
        }
        .tint(Color.brandPrimary)
        .environmentObject(favourites)
        .onChange(of: openFavouritesFromWidget) { _, flag in
            guard flag else { return }
            // Determine favourites tab index dynamically (depends on whether favourites tab is present)
            if showFavouritesTab && !favourites.favouriteStops.isEmpty {
                selectedTab =  showFavouritesTab && !favourites.favouriteStops.isEmpty ? 2 : 0
            }
        }
    }
}

// MARK: - Stop Popup Modern Component
private struct StopPopupView: View {
    let stop: BusStop
    let isFavourite: Bool
    let isLoading: Bool
    let times: [String]
    let onToggleFavourite: () -> Void
    let onClose: () -> Void
    let onOpenTimetable: () -> Void
    let onRequestDirections: () -> Void
    @AppStorage("mapShowDirectionsButton") private var mapShowDirectionsButton: Bool = true

    // Design tokens
    private var cornerRadius: CGFloat { 18 }
    private var separatorColor: Color { Color.primary.opacity(0.12) }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0)
            content
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .frame(maxWidth: 480)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Stop: \(stop.name)")
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isLoading)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.stopPink.opacity(0.15))
                Image(systemName: "mappin.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.stopPink, Color.white)
            }
            .frame(width: 40, height: 40)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Button(action: onOpenTimetable) {
                        Text(stop.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Open timetable for \(stop.name)")
                    favouriteButton
                    if mapShowDirectionsButton {
                        directionsButton
                    }
                }
                Text("Live departures")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 4)
            closeButton
        }
        .padding(.bottom, 4)
    }

    @State private var now: Date = Date()
    private var upcoming: [BusUpcomingTime] { BusTimeFormatter.upcomingTimes(from: times, now: now) }
    // Matched routes for each upcoming time (HH:mm -> routeID)
    @State private var matchedRoutes: [String: String] = [:]
    @State private var deviationMinutes: [String: Int] = [:] // HH:mm -> deviation (live - scheduled)
    private let deviationThreshold = 3 // minutes for highlighting lateness/earliness
    // Sub-minute smoothing: 15s ticks; re-render only on minute change
    @State private var lastRenderedMinute: Int = Calendar.current.component(.minute, from: Date())
    private var minuteTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    }

    private var content: some View {
        Group {
            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Loading departures…")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 2)
            } else if upcoming.isEmpty {
                Text("No upcoming buses found")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(upcoming.prefix(5)) { item in
                        HStack(spacing: 10) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundStyle(Color.stopPink)
                            Text(item.time)
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.primary)
                            // Countdown moved directly after time
                            Text("(\(item.intervalDescription))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            if let route = matchedRoutes[item.time] {
                                Text("Route \(route)")
                                    .font(.footnote.weight(.semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.brandPrimary.opacity(0.18)))
                                    .foregroundStyle(Color.brandPrimary)
                            }
                            if let dev = deviationMinutes[item.time] {
                                let absDev = abs(dev)
                                if absDev >= deviationThreshold {
                                    Text(dev > 0 ? "+\(absDev)m" : "-\(absDev)m")
                                        .font(.footnote.monospacedDigit())
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                .fill(dev > 0 ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                                        )
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.primary.opacity(0.04))
                        )
                        .accessibilityLabel("Departure at \(item.time) \(item.intervalDescription)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .contain)
                .padding(.top, 4)
                legend
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
        .onReceive(minuteTimer) { date in
            let minute = Calendar.current.component(.minute, from: date)
            if minute != lastRenderedMinute {
                lastRenderedMinute = minute
                now = date
                Task { await matchRoutes() }
            }
        }
        .onAppear {
            now = Date()
            lastRenderedMinute = Calendar.current.component(.minute, from: now)
            Task { await matchRoutes() }
        }
    }

    // (Interval logic unified via BusTimeFormatter)

    private var favouriteButton: some View {
        Button(action: onToggleFavourite) {
            Image(systemName: isFavourite ? "heart.fill" : "heart")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(isFavourite ? Color.red : Color.secondary)
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavourite ? "Remove favourite" : "Add favourite")
        .accessibilityAddTraits(.isButton)
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .padding(8)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close stop details")
    }

    private var directionsButton: some View {
        Button(action: onRequestDirections) {
            HStack(spacing: 6) {
                Image(systemName: "figure.walk")
                    .font(.caption.weight(.semibold))
                Text("Walk")
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.brandPrimary.opacity(0.16))
            )
            .foregroundStyle(Color.brandPrimary)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Get walking directions to \(stop.name)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Timetable Cross-Matching
private extension StopPopupView {
    /// Attempt to map live upcoming HH:mm times to scheduled timetable route IDs.
    /// Strategy: For each displayed time, find the timetable entry with exact same minute (or within +/-1 minute if exact absent) for current service day & direction.
    func matchRoutes() async {
        // Need direction context: infer by membership in StopsData arrays.
        let direction: RouteDirection = StopsData.toCity.contains(stop) ? .toCity : .toSwords
        let service = TimetableStore.serviceDay(for: Date())
        let scheduled = TimetableStore.allEntries(for: stop, direction: direction, service: service)
        guard !scheduled.isEmpty else { return }
        var map: [String: String] = [:]
        // Pre-index scheduled by time for O(1) lookups
        var byTime: [String: [String]] = [:] // time -> [routeID]
        for e in scheduled { byTime[e.time, default: []].append(e.route) }
        func parse(_ t: String) -> (Int, Int)? {
            let parts = t.split(separator: ":"); if parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) { return (h, m) } else { return nil }
        }
        // Build neighbor lookup (±1 minute) for fuzzy matching
        for upcomingTime in upcoming.prefix(5) {
            guard map[upcomingTime.time] == nil else { continue }
            if let routes = byTime[upcomingTime.time] { map[upcomingTime.time] = routes.first; continue }
            // Fuzzy: +/- 1 minute
            if let (h, m) = parse(upcomingTime.time) {
                let candidates = [m - 1, m + 1].compactMap { mm -> String? in
                    guard (0..<60).contains(mm) else { return nil }
                    let hh = h + (mm == -1 ? -1 : (mm == 60 ? 1 : 0))
                    if hh < 0 || hh > 23 { return nil }
                    let adjM = (mm + 60) % 60
                    return String(format: "%02d:%02d", hh, adjM)
                }
                for cand in candidates {
                    if let routes = byTime[cand] { map[upcomingTime.time] = routes.first; break }
                }
            }
        }
        await MainActor.run { self.matchedRoutes = map }
    }

    @ViewBuilder var legend: some View {
        if !matchedRoutes.isEmpty {
            HStack(spacing: 12) {
                if deviationMinutes.values.contains(where: { abs($0) >= deviationThreshold }) {
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.orange.opacity(0.35)).frame(width: 14, height: 14)
                        Text("Late")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.green.opacity(0.35)).frame(width: 14, height: 14)
                        Text("Early")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("Route inferred from timetable")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 6)
            .transition(.opacity)
        }
    }
}

// MARK: - Bus Popup Modern Component
private struct BusPopupView: View {
    let bus: Bus
    let onClose: () -> Void

    @State private var now: Date = Date()
    @State private var lastRenderedSecond: Int = Calendar.current.component(.second, from: Date())
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher> {
        // Update every 15s for age & dynamic speed classification
        Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    }

    private var ageDescription: String {
        guard let ts = bus.lastUpdated else { return "—" }
        let interval = now.timeIntervalSince(ts)
        if interval < 30 { return "just now" }
        let minutes = Int(interval / 60)
        if minutes < 1 { return "< 1 min" }
        if minutes == 1 { return "1 min ago" }
        if minutes < 60 { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours == 1 { return "1 hr ago" }
        return "\(hours) hr ago" }

    // Expand compass codes to human-readable phrases
    private func expandedDirection(from code: String) -> String {
        let c = code.uppercased()
        switch c {
        case "N": return "North"
        case "S": return "South"
        case "E": return "East"
        case "W": return "West"
        case "NE": return "North East"
        case "NW": return "North West"
        case "SE": return "South East"
        case "SW": return "South West"
        default:
            // Simplify longer 3-letter forms to nearest major/intercardinal where possible
            if c.contains("N") && c.contains("E") { return "North East" }
            if c.contains("N") && c.contains("W") { return "North West" }
            if c.contains("S") && c.contains("E") { return "South East" }
            if c.contains("S") && c.contains("W") { return "South West" }
            return c
        }
    }

    private var travelLine: String? {
        let directionExpanded: String? = {
            guard let dir = bus.compass, !dir.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
            return expandedDirection(from: dir)
        }()
        let speedValue: Double? = {
            guard let raw = bus.speed else { return nil }
            return extractSpeedValue(from: raw)
        }()
        // Build sentence variants
        switch (directionExpanded, speedValue) {
        case (nil, nil):
            return nil
        case (let d?, nil):
            return "Travelling \(d)"
        case (nil, let s?):
            return "Travelling at \(Int(round(s))) kmph"
        case (let d?, let s?):
            return "Travelling \(d) at \(Int(round(s))) kmph"
        }
    }

    // Attempts to parse a numeric speed from arbitrary provider strings (e.g. "35", "35.2", "35 km/h", " 12.0 ")
    private func extractSpeedValue(from raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let direct = Double(trimmed) { return direct }
        // Filter to digits & single dot
        var numeric = ""
        var dotUsed = false
        for ch in trimmed { if ch.isNumber { numeric.append(ch) } else if ch == ".", !dotUsed { numeric.append(ch); dotUsed = true } }
        if numeric.isEmpty { return nil }
        return Double(numeric)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            details
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .frame(maxWidth: 480)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Bus \(bus.id)")
        .onReceive(timer) { date in
            // Only update 'now' at 15s cadence
            now = date
        }
        .onAppear { now = Date() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.brandPrimary.opacity(0.15))
                Image(systemName: "bus.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.brandPrimary)
            }
            .frame(width: 48, height: 48)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("Bus \(bus.id)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    if !bus.inService {
                        Text("Not in service")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.secondary.opacity(0.15)))
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Following")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.brandPrimary.opacity(0.15)))
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
                Text("Updated \(ageDescription)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Circle().fill(Color.primary.opacity(0.06)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close bus details")
        }
        .padding(.bottom, 6)
    }

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let line = travelLine {
                HStack(spacing: 10) {
                    Image(systemName: "location.north.line")
                        .font(.caption)
                        .foregroundStyle(Color.brandPrimary)
                    Text(line)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
            } else {
                Text("No movement data")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity)
    }
}

struct LiveView: View {
    let onOpenTimetable: (BusStop) -> Void
    @StateObject private var routeStore = RouteStore()
    @EnvironmentObject private var favourites: FavouritesStore
    @AppStorage("mapShowUserLocation") private var mapShowUserLocation: Bool = false
    @StateObject private var locationPermission = LocationPermissionManager()
    @State private var pendingDirectionsStop: BusStop? = nil
    @State private var showLocationDeniedAlert = false
    @State private var showDirectionsErrorAlert = false
    @State private var directionsErrorMessage: String = ""
    @State private var walkingRouteCoordinates: [CLLocationCoordinate2D] = []
    @State private var isLowPowerModeEnabled: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
    @AppStorage("allowLowPowerOverride") private var allowLowPowerOverride: Bool = false

    private let lowPowerModePublisher = NotificationCenter.default.publisher(for: .NSProcessInfoPowerStateDidChange)

    // MARK: - Map State
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 53.4525, longitude: -6.2195), // Swords-ish
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )
    private let initialRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.4525, longitude: -6.2195),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    // MARK: - Route & Direction Selection
    @State private var availableRoutes: [Route] = []
    @State private var selectedRoute: Route? = nil
    @State private var direction: RouteDirection = .toSwords
    @State private var isFetching = false
    @State private var selectedBus: Bus? = nil
    @State private var isFollowingSelectedBus: Bool = false
    @State private var showNoBusesBanner: Bool = false
    @State private var showLowPowerBanner: Bool = false
    @State private var suppressedLowPowerBanner: Bool = false
    @State private var controlPanelWidth: CGFloat = 0
    @State private var availableWidth: CGFloat = 0
    @State private var suppressedNoBusesBanner: Bool = false // prevents re-show within same hidden-bus period after manual dismiss

    @State private var buses: [Bus] = []
    // Interpolated buses used for rendering with smooth movement
    @State private var displayBuses: [Bus] = []
    // Per-bus interpolation tasks
    @State private var busAnimationTasks: [String: Task<Void, Never>] = [:]
    @State private var snappedPolyline: [CLLocationCoordinate2D] = []
    @State private var isSnapping = false

    @State private var selectedBusStop: BusStop? = nil
    @State private var nextBusTimes: [String] = []
    @State private var isLoadingNextBusTimes = false
    // Animated stop annotation state
    @State private var displayStops: [BusStop] = []
    @State private var disappearingStopIDs: Set<BusStop.ID> = []

    private var stopsForSelectedDirection: [BusStop] {
        direction == .toSwords ? StopsData.toSwords : StopsData.toCity
    }
    
    // Helper to measure text width for menu width
    private func widthForMenu(titles: [String]) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let maxWidth = titles.map { (title: String) -> CGFloat in
            return (title as NSString).size(withAttributes: attributes).width
        }.max() ?? 0
        // Add padding for menu chrome and disclosure indicator
        return max(120, maxWidth + 44)
    }
    
    private var filteredRoutesForDirection: [Route] {
        // Determine direction identifier used by route data
        let dirID = (direction == .toSwords) ? "toSwords" : "toCity"

        // If RouteStore exposes direction availability per route, use it; otherwise return all routes
        // We avoid any dynamic member lookup or bindings here to prevent compiler errors.
        let models = routeStore.routes
        var results: [Route] = []
        for model in models {
            if routeStoreSupportsDirection(routeID: model.id, directionID: dirID) {
                results.append(Route(id: model.id, name: model.name))
            }
        }
        return results
    }
    
    private func routeStoreSupportsDirection(routeID: String, directionID: String) -> Bool {
        // Check whether the loaded route definition actually includes a direction with this id
        guard let def = routeStore.route(withID: routeID) else { return false }
        return def.directions.contains { $0.id == directionID }
    }

    private var routePickerWidth: CGFloat {
        let titles = ["Routes"] + filteredRoutesForDirection.map { $0.name }
        return widthForMenu(titles: titles)
    }

    private func loadSnappedPolyline() {
        guard let route = selectedRoute else {
            withAnimation(.easeInOut(duration: 0.35)) { snappedPolyline = [] }
            return
        }
        let dirID = (direction == .toSwords) ? "toSwords" : "toCity"
        isSnapping = !(isLowPowerModeEnabled && !allowLowPowerOverride)
        Task {
            let segments = routeStore.polylineCoordinates(for: route.id, directionID: dirID)
            let raw = segments.flatMap { $0 }
            do {
                if isLowPowerModeEnabled && !allowLowPowerOverride {
                    await MainActor.run {
                        withAnimation(.easeInOut(duration: 0.35)) { snappedPolyline = raw }
                        isSnapping = false
                    }
                    return
                }
                let snapped = try await RouteSnappingService.shared.snappedSegment(routeID: route.id, directionID: dirID, raw: raw)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) { snappedPolyline = snapped }
                    isSnapping = false
                }
            } catch {
                print("Snapping failed: \(error)")
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.5)) { snappedPolyline = raw }
                    isSnapping = false
                }
            }
        }
    }
    
    private func centerMap(on coordinate: CLLocationCoordinate2D) {
        // Default centering with a standard span (used when not already following or for initial focus)
        let span = MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        withAnimation(.easeInOut(duration: 0.35)) { cameraPosition = .region(region) }
        lastRegion = region
    }

    @State private var lastRegion: MKCoordinateRegion? = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.4525, longitude: -6.2195),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    private func panMapPreservingZoom(to coordinate: CLLocationCoordinate2D) {
        // Keep the current zoom level (span) exactly as-is; never enlarge automatically while following.
        // Use lastRegion span if available, otherwise fallback to a sensible default.
        let currentSpan = lastRegion?.span ?? MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
        let region = MKCoordinateRegion(center: coordinate, span: currentSpan)
        withAnimation(.easeInOut(duration: 0.35)) { cameraPosition = .region(region) }
        lastRegion = region
    }

    private let timestampFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()

    private func fetchBuses() async {
        if Task.isCancelled { return }
        guard !isFetching else { return }
        isFetching = true
        defer { isFetching = false }
        let url = URL(string: "https://www.swordsexpress.com/app/themes/swordsexpress/resources/assets/scripts/latlong.php")!
        do {
    // deviation calculation removed (handled elsewhere if needed)
            let (data, _) = try await URLSession.shared.data(from: url)
            if Task.isCancelled { return }
            guard let raw = try JSONSerialization.jsonObject(with: data) as? [[Any]] else { return }
            // Detect scenario where all buses are hidden
            let visible = raw.filter { $0.count >= 2 && ($0[1] as? String) != "hidden" }
            if visible.isEmpty {
                await MainActor.run {
                    // Only show banner if not currently suppressed (user manually dismissed during this hidden-only period)
                    if !showNoBusesBanner && !suppressedNoBusesBanner {
                        showNoBusesBanner = true
                    }
                }
            } else if showNoBusesBanner {
                await MainActor.run {
                    showNoBusesBanner = false
                    suppressedNoBusesBanner = false // reset suppression when buses reappear
                }
            } else if !visible.isEmpty && suppressedNoBusesBanner {
                // Buses reappeared after being hidden; clear suppression so future hidden period can show banner again
                await MainActor.run { suppressedNoBusesBanner = false }
            }
            var next: [Bus] = []
            for entry in raw {
                if entry.count >= 2, let _ = entry[0] as? String, let second = entry[1] as? String, second == "hidden" { continue }
                if entry.count >= 7,
                   let id = entry[0] as? String,
                   let latStr = entry[1] as? String, let lat = Double(latStr),
                   let lonStr = entry[2] as? String, let lon = Double(lonStr),
                   let tsStr = entry[3] as? String,
                   let svcStr = entry[4] as? String,
                   let speed = entry[5] as? String,
                   let compass = entry[6] as? String {
                    let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                    let inService = (svcStr == "1")
                    let ts = timestampFormatter.date(from: tsStr)
                    let bus = Bus(id: id, coordinate: coord, bearing: 0, speed: speed, lastUpdated: ts, compass: compass, inService: inService)
                    next.append(bus)
                }
            }
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.buses = next
                }
                if displayBuses.isEmpty {
                    displayBuses = next
                } else {
                    animateBusPositions(to: next)
                }
                // If following a selected bus, recenter when its coordinate changes
                if let selected = self.selectedBus,
                   let updated = next.first(where: { $0.id == selected.id }) {
                    // Update the selectedBus reference to the updated one so its details (time/speed) refresh
                    self.selectedBus = updated
                    if self.isFollowingSelectedBus { self.panMapPreservingZoom(to: updated.coordinate) }
                }
            }
        } catch {
            if let urlErr = error as? URLError, urlErr.code == .cancelled { return } // ignore expected cancellation noise
            if (error as NSError).code == NSURLErrorCancelled { return }
            print("Bus fetch failed: \(error)")
        }
    }

    private func loadNextBusTimes(for stop: BusStop) {
        let directionString = direction == .toSwords ? "city_to_swords" : "swords_to_city"
    let stopParam = stop.slug
        isLoadingNextBusTimes = true
        Task {
            do {
                let times = try await fetchNextBusTimes(direction: directionString, stop: stopParam)
                await MainActor.run {
                    self.nextBusTimes = times
                    self.isLoadingNextBusTimes = false
                }
            } catch {
                print("Failed to fetch next bus times: \(error)")
                await MainActor.run {
                    self.nextBusTimes = []
                    self.isLoadingNextBusTimes = false
                }
            }
        }
    }

    private func requestDirections(to stop: BusStop) {
        switch locationPermission.authorizationStatus {
        case .notDetermined:
            pendingDirectionsStop = stop
            locationPermission.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            pendingDirectionsStop = stop
            if let current = locationPermission.lastLocation?.coordinate {
                calculateWalkingRoute(to: stop, from: current)
                pendingDirectionsStop = nil
            } else {
                locationPermission.requestLocation()
            }
        default:
            showLocationDeniedAlert = true
        }
    }

    private func calculateWalkingRoute(to stop: BusStop, from current: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: current))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: stop.coordinate))
        request.transportType = .walking
        let directions = MKDirections(request: request)
        Task {
            do {
                let response = try await directions.calculate()
                let coords = response.routes.first?.polyline.coordinates ?? []
                await MainActor.run {
                    if coords.isEmpty {
                        self.walkingRouteCoordinates = []
                        self.directionsErrorMessage = "No walking route found from your location to this stop."
                        self.showDirectionsErrorAlert = true
                    } else {
                        self.walkingRouteCoordinates = coords
                    }
                }
            } catch {
                await MainActor.run {
                    self.walkingRouteCoordinates = []
                    self.directionsErrorMessage = "Unable to calculate walking directions right now."
                    self.showDirectionsErrorAlert = true
                }
            }
        }
    }

    private var mapInteraction: MapInteractionModes { [.all] }

    private var mapView: some View {
        Map(position: $cameraPosition, interactionModes: mapInteraction) {
            RoutePolylineView(coordinates: snappedPolyline)
            if walkingRouteCoordinates.count > 1 {
                MapPolyline(coordinates: walkingRouteCoordinates)
                    .stroke(Color.blue, lineWidth: 4)
            }

            BusAnnotationsContent(
                buses: displayBuses.isEmpty ? buses : displayBuses,
                selectedBus: selectedBus,
                onTap: { bus in
                    selectedBus = bus
                    // Dismiss any selected stop when a bus is chosen
                    selectedBusStop = nil
                    // Auto-enable follow when a bus is selected
                    isFollowingSelectedBus = true
                    // Initial selection: do not change zoom if already following something; if first selection, keep behavior
                    if isFollowingSelectedBus { panMapPreservingZoom(to: bus.coordinate) } else { centerMap(on: bus.coordinate) }
                }
            )

            StopAnnotationsContent(
                stops: displayStops,
                selectedStop: selectedBusStop,
                onTap: { stop in
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        selectedBusStop = stop
                        nextBusTimes = []
                        selectedBus = nil
                        isFollowingSelectedBus = false
                    }
                    walkingRouteCoordinates = []
                    centerMap(on: stop.coordinate)
                    loadNextBusTimes(for: stop)
                },
                disappearingIDs: disappearingStopIDs
            )

            if mapShowUserLocation, let coordinate = locationPermission.lastLocation?.coordinate {
                Annotation("My Location", coordinate: coordinate) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.25))
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                    .accessibilityHidden(true)
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: buses)
        .ignoresSafeArea()
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .simultaneousGesture(TapGesture().onEnded {
            if !isFollowingSelectedBus { selectedBus = nil }
            selectedBusStop = nil
            walkingRouteCoordinates = []
        })
        // Capture pinch zoom gestures to refine lastRegion span so follow never reverts to an older (wider) zoom.
        .simultaneousGesture(
            MagnificationGesture()
                .onEnded { scale in
                    guard scale != 0, scale != 1, let lr = lastRegion else { return }
                    // Smaller scale(<1) means user pinched inward? SwiftUI magnification returns relative >1 when zooming in.
                    // When zooming in (scale > 1) we want smaller span (divide by scale).
                    // When zooming out (scale < 1) we enlarge span, but to honor "never zoom out automatically" we still record it
                    // so future follows keep exactly what user set manually.
                    let adjusted = MKCoordinateSpan(
                        latitudeDelta: max(lr.span.latitudeDelta / scale, 0.0005),
                        longitudeDelta: max(lr.span.longitudeDelta / scale, 0.0005)
                    )
                    lastRegion = MKCoordinateRegion(center: lr.center, span: adjusted)
                }
        )
    }

    private func showLowPowerBannerIfNeeded() {
        guard isLowPowerModeEnabled, !allowLowPowerOverride, !suppressedLowPowerBanner else { return }
        showLowPowerBanner = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            if showLowPowerBanner { showLowPowerBanner = false }
        }
    }

    var body: some View {
        GeometryReader { outerGeo in
            let maxWidth = outerGeo.size.width
            ZStack(alignment: .top) {
            mapView


            // Controls overlay
            VStack(spacing: 8) {
                if showLowPowerBanner {
                    HStack(spacing: 12) {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(Color.yellow)
                        Text("Live updates are less frequent while Low Power Mode is on")
                            .font(.subheadline.weight(.semibold))
                        Spacer(minLength: 4)
                        Button(action: {
                            withAnimation {
                                showLowPowerBanner = false
                                suppressedLowPowerBanner = true
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.caption.bold())
                                .padding(6)
                                .background(Circle().fill(Color.primary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    )
                    .overlay(
                        Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
                    .padding(.top, 8)
                    .frame(width: controlPanelWidth == 0 ? nil : min(controlPanelWidth, availableWidth > 0 ? availableWidth - 32 : controlPanelWidth))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                if showNoBusesBanner {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.yellow)
                        Text("No buses are currently running")
                            .font(.subheadline.weight(.semibold))
                        Spacer(minLength: 4)
                        Button(action: { withAnimation { showNoBusesBanner = false; suppressedNoBusesBanner = true } }) {
                            Image(systemName: "xmark")
                                .font(.caption.bold())
                                .padding(6)
                                .background(Circle().fill(Color.primary.opacity(0.08)))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                    )
                    .overlay(
                        Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )
                    .padding(.top, 8)
                    .frame(width: controlPanelWidth == 0 ? nil : min(controlPanelWidth, availableWidth > 0 ? availableWidth - 32 : controlPanelWidth))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                HStack(spacing: 8) {
                    // Direction Picker
                    Picker("Direction", selection: $direction) {
                        Text("To Swords").tag(RouteDirection.toSwords)
                        Text("To City").tag(RouteDirection.toCity)
                    }
                    .pickerStyle(.segmented)
                    // Route Picker
                    Picker("Route", selection: $selectedRoute) {
                        Text("Routes").tag(Route?.none)
                        ForEach(filteredRoutesForDirection) { route in
                            Text(route.name).tag(Route?.some(route))
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(minWidth: routePickerWidth)
                }
                .padding(10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                // Allow it to grow but cap to available width minus margins, and ensure a comfortable minimum width
                .frame(minWidth: 320, maxWidth: min(availableWidth - 32, 560), alignment: .leading)
                .padding(.horizontal)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: ControlPanelWidthKey.self, value: proxy.size.width)
                    }
                )

                Spacer(minLength: 0)
            }
            .padding(.top, 8)

            // Removed full-screen dismiss overlays for bus and bus stop popups

            // Bus popup (modernized)
            if let selected = selectedBus {
                BusPopupView(
                    bus: selected,
                    onClose: {
                        withAnimation { isFollowingSelectedBus = false; selectedBus = nil }
                    }
                )
                .padding(.horizontal)
                .padding(.top, 72)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(2)
            }

            // Bus stop popup (modernized)
            if let stop = selectedBusStop {
                StopPopupView(
                    stop: stop,
                    isFavourite: favourites.isFavourite(stop),
                    isLoading: isLoadingNextBusTimes,
                    times: nextBusTimes,
                    onToggleFavourite: { favourites.toggle(stop) },
                    onClose: { withAnimation { selectedBusStop = nil }; walkingRouteCoordinates = [] },
                    onOpenTimetable: {
                        let target = stop
                        withAnimation { selectedBusStop = nil }
                        walkingRouteCoordinates = []
                        onOpenTimetable(target)
                    },
                    onRequestDirections: {
                        requestDirections(to: stop)
                    }
                )
                .padding(.horizontal)
                .padding(.top, 72)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(2)
            }
            }
            .onAppear { availableWidth = maxWidth }
            .onAppear {
                if displayStops.isEmpty { displayStops = stopsForSelectedDirection }
                isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
                showLowPowerBannerIfNeeded()
            }
            .onChange(of: maxWidth) { _, newVal in availableWidth = newVal }
            .onPreferenceChange(ControlPanelWidthKey.self) { newWidth in
                if newWidth > 0 { controlPanelWidth = newWidth }
            }
        }
        .onChange(of: selectedRoute) { oldValue, newValue in
            guard oldValue?.id != newValue?.id else { return }
            loadSnappedPolyline()
            isFollowingSelectedBus = false
        }
        .onChange(of: direction) { oldValue, newValue in
            guard oldValue != newValue else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                let dirID = (direction == .toSwords) ? "toSwords" : "toCity"
                if let sel = selectedRoute, !routeStoreSupportsDirection(routeID: sel.id, directionID: dirID) {
                    selectedRoute = nil
                }
                // Clear any selected stop when direction changes so its popup animates out cleanly
                selectedBusStop = nil
                isFollowingSelectedBus = false
                loadSnappedPolyline()
            }
            updateDisplayedStops()
        }
        .task {
            // Load routes from bundle once
            do {
                try routeStore.loadFromBundle()
                refreshRoutesFromStore()
                loadSnappedPolyline()
            } catch {
                print("Failed to load routes.json: \(error)")
            }
            // Initial bus load
            await fetchBuses()
            // Poll every 5 seconds until task cancelled (throttled in Low Power Mode unless overridden)
            while !Task.isCancelled {
                let interval: UInt64 = (isLowPowerModeEnabled && !allowLowPowerOverride) ? 20_000_000_000 : 5_000_000_000
                do { try await Task.sleep(nanoseconds: interval) } catch { break }
                if Task.isCancelled { break }
                await fetchBuses()
            }
        }
        .onReceive(lowPowerModePublisher) { _ in
            let enabled = ProcessInfo.processInfo.isLowPowerModeEnabled
            isLowPowerModeEnabled = enabled
            if enabled {
                showLowPowerBannerIfNeeded()
            } else {
                showLowPowerBanner = false
                suppressedLowPowerBanner = false
            }
        }
        .onChange(of: allowLowPowerOverride) { _, newValue in
            if newValue {
                showLowPowerBanner = false
                suppressedLowPowerBanner = false
            } else {
                showLowPowerBannerIfNeeded()
            }
        }
        .onChange(of: locationPermission.authorizationStatus) { _, status in
            guard let pending = pendingDirectionsStop else { return }
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                if let current = locationPermission.lastLocation?.coordinate {
                    calculateWalkingRoute(to: pending, from: current)
                    pendingDirectionsStop = nil
                } else {
                    locationPermission.requestLocation()
                }
            case .denied, .restricted:
                showLocationDeniedAlert = true
                pendingDirectionsStop = nil
            default:
                break
            }
        }
        .onChange(of: locationPermission.lastLocation) { _, newLocation in
            let status = locationPermission.authorizationStatus
            guard let pending = pendingDirectionsStop,
                  let current = newLocation?.coordinate,
                  status == .authorizedAlways || status == .authorizedWhenInUse
            else { return }
            calculateWalkingRoute(to: pending, from: current)
            pendingDirectionsStop = nil
        }
        .alert("Location Access Needed", isPresented: $showLocationDeniedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable location access in Settings to get walking directions from your current location.")
        }
        .alert("Directions Unavailable", isPresented: $showDirectionsErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(directionsErrorMessage)
        }
    }

    private func refreshRoutesFromStore() {
        let mapped = routeStore.routes.map { Route(id: $0.id, name: $0.name) }
        self.availableRoutes = mapped
    }

    // MARK: - Smooth Bus Animation
    private func animateBusPositions(to newBuses: [Bus]) {
        if isLowPowerModeEnabled && !allowLowPowerOverride {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayBuses = newBuses
            }
            return
        }
        let currentIDs = Set(displayBuses.map { $0.id })
        let newIDs = Set(newBuses.map { $0.id })

        // Remove buses that disappeared
        let removed = currentIDs.subtracting(newIDs)
        if !removed.isEmpty {
            for id in removed { busAnimationTasks[id]?.cancel() }
            withAnimation(.easeInOut(duration: 0.35)) {
                displayBuses.removeAll { removed.contains($0.id) }
            }
        }

        // Add new buses
        let added = newBuses.filter { !currentIDs.contains($0.id) }
        if !added.isEmpty {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                displayBuses.append(contentsOf: added)
            }
        }

        // Interpolate existing buses
        let duration: Double = 0.6
        let steps = 24
        let stepInterval = duration / Double(steps)
        let jitterMeters: Double = 2

        func distance(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
            let earthRadius = 6_371_000.0
            let dLat = (b.latitude - a.latitude) * .pi / 180
            let dLon = (b.longitude - a.longitude) * .pi / 180
            let lat1 = a.latitude * .pi / 180
            let lat2 = b.latitude * .pi / 180
            let hav = sin(dLat/2)*sin(dLat/2) + sin(dLon/2)*sin(dLon/2)*cos(lat1)*cos(lat2)
            let c = 2 * atan2(sqrt(hav), sqrt(1-hav))
            return earthRadius * c
        }

        for newBus in newBuses {
            guard let index = displayBuses.firstIndex(where: { $0.id == newBus.id }) else { continue }
            let start = displayBuses[index].coordinate
            let end = newBus.coordinate
            if distance(start, end) < jitterMeters {
                // Replace with new struct (ensures Equatable diff notices changes beyond coordinate movement threshold)
                var updated = displayBuses[index]
                updated.speed = newBus.speed
                updated.lastUpdated = newBus.lastUpdated
                updated.compass = newBus.compass
                updated.inService = newBus.inService
                displayBuses[index] = updated
                continue
            }
            // Cancel running animation
            busAnimationTasks[newBus.id]?.cancel()
            let id = newBus.id
            let task = Task { @MainActor in
                for step in 1...steps {
                    if Task.isCancelled { return }
                    let t = Double(step) / Double(steps)
                    let lat = start.latitude + (end.latitude - start.latitude) * t
                    let lon = start.longitude + (end.longitude - start.longitude) * t
                    if let i = displayBuses.firstIndex(where: { $0.id == id }) {
                        var moving = displayBuses[i]
                        moving.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        if step == steps {
                            moving.speed = newBus.speed
                            moving.lastUpdated = newBus.lastUpdated
                            moving.compass = newBus.compass
                            moving.inService = newBus.inService
                        }
                        displayBuses[i] = moving
                        if isFollowingSelectedBus, selectedBus?.id == id, step % 4 == 0 { panMapPreservingZoom(to: moving.coordinate) }
                    }
                    try? await Task.sleep(nanoseconds: UInt64(stepInterval * 1_000_000_000))
                }
            }
            busAnimationTasks[newBus.id] = task
        }
    }

    // MARK: - Animated Stop Updates
    private func updateDisplayedStops() {
        let newStops = stopsForSelectedDirection
        let oldSet = Set(displayStops.map { $0.id })
        let newSet = Set(newStops.map { $0.id })
        let removed = oldSet.subtracting(newSet)
        let added = newSet.subtracting(oldSet)

        // Mark removed for shrink/opacity animation, then remove after delay
        if !removed.isEmpty {
            disappearingStopIDs.formUnion(removed)
            // Remove models after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    displayStops.removeAll { disappearingStopIDs.contains($0.id) }
                    disappearingStopIDs.subtract(removed)
                }
            }
        }

        // Append added stops with initial tiny scale via transition
        if !added.isEmpty {
            let toAdd = newStops.filter { added.contains($0.id) }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                displayStops.append(contentsOf: toAdd)
            }
        }

        // Reorder to match newStops ordering for consistency
        if removed.isEmpty && added.isEmpty {
            // Only direction change with same set; simply reorder
            displayStops = newStops
        } else {
            // After animations finish, align ordering
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                displayStops = displayStops.sorted { a, b in
                    guard let ia = newStops.firstIndex(of: a), let ib = newStops.firstIndex(of: b) else { return a.id < b.id }
                    return ia < ib
                }
            }
        }
    }
}

private extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: .init(), count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

// MARK: - Timetable
struct ScheduleView: View {
    @State private var searchText: String = ""
    @EnvironmentObject private var favourites: FavouritesStore

    private func stops(for direction: RouteDirection) -> [BusStop] {
        let all = (direction == .toSwords) ? StopsData.toSwords : StopsData.toCity
        guard !searchText.isEmpty else { return all }
        return all.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Choose direction") {
                    NavigationLink(value: RouteDirection.toCity) {
                        Label("To City", systemImage: "building.2")
                    }
                    NavigationLink(value: RouteDirection.toSwords) {
                        Label("To Swords", systemImage: "bus")
                    }
                }
            }
            .navigationDestination(for: RouteDirection.self) { direction in
                StopsListView(direction: direction, searchText: $searchText)
            }
            .navigationDestination(for: BusStop.self) { stop in
                // We need the direction to continue; deduce from presence in lists
                // Prefer toCity first; if not found, it's toSwords
                let direction: RouteDirection = StopsData.toCity.contains(stop) ? .toCity : .toSwords
                StopTimetableView(direction: direction, stop: stop)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        FavouriteStopsView()
                    } label: {
                        Image(systemName: favourites.favouriteStops.isEmpty ? "heart" : "heart.fill")
                    }
                    .accessibilityLabel("Favourite Stops")
                }
            }
            .navigationTitle("Timetable")
        }
    }
}

private struct StopsListView: View {
    let direction: RouteDirection
    @Binding var searchText: String

    private var stops: [BusStop] {
        let base = (direction == .toSwords) ? StopsData.toSwords : StopsData.toCity
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List(stops) { stop in
            NavigationLink(value: stop) {
                VStack(alignment: .leading) {
                    Text(stop.name)
                    Text(direction == .toSwords ? "To Swords" : "To City")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(direction == .toSwords ? "To Swords" : "To City")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

// (Removed duplicate corrupted StopTimetableView definition)

// (TimetableEntry & fetchTimetable moved to Models.swift / Networking.swift)

// (Route, RouteDirection & Bus definitions removed; now sourced from Models.swift)

// MARK: - Favourite Stops List
struct FavouriteStopsView: View {
    @EnvironmentObject private var favourites: FavouritesStore
    
    @AppStorage("favouritesOrder") private var favouritesOrderRaw: String = ""
    
    private var storedOrderIDs: [String] {
        favouritesOrderRaw.split(separator: ",").map { String($0) }
    }

    private func orderedStops(from stops: [BusStop]) -> [BusStop] {
        // Build index keyed by Int stop ID (ignore any malformed stored values)
        let idIndex: [Int: Int] = Dictionary(uniqueKeysWithValues: storedOrderIDs.enumerated().compactMap { (idx, raw) in
            if let id = Int(raw) { return (id, idx) } else { return nil }
        })
        // Sort by stored index first; unknown IDs fall back to their existing order but after known ones
        return stops.sorted { a, b in
            let ia = idIndex[a.id] ?? Int.max
            let ib = idIndex[b.id] ?? Int.max
            if ia == ib { return a.name < b.name } // stable fallback by name for unknowns
            return ia < ib
        }
    }

    private func saveOrder(for stops: [BusStop]) {
        let ids = stops.map { String($0.id) }
        let joined = ids.joined(separator: ",")
        favouritesOrderRaw = joined
        // Mirror into App Group so widget can respect ordering
        if let defaults = UserDefaults(suiteName: SharedConstants.appGroupIdentifier) {
            defaults.set(joined, forKey: SharedConstants.favouriteStopOrderKey)
        }
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "LiveDepartures")
        #endif
    }

    var body: some View {
        List {
            if favourites.favouriteStops.isEmpty {
                Text("No favourite stops yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(orderedStops(from: favourites.favouriteStops)) { stop in
                    // NOTE: Using an explicit destination NavigationLink here instead of value-based navigation.
                    // Mixing value-based links (NavigationLink(value:)) with an intermediate push created using
                    // the older initializer (toolbar NavigationLink to FavouriteStopsView) was causing SwiftUI
                    // to momentarily re-present this view after pushing the stop timetable, producing the bug
                    // where the favourites list "reappears" until navigating back. Providing the destination
                    // directly stabilises the stack and resolves the glitch.
                    NavigationLink {
                        let direction: RouteDirection = StopsData.toCity.contains(stop) ? .toCity : .toSwords
                        StopTimetableView(direction: direction, stop: stop)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin")
                                .foregroundStyle(Color.stopPink)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(stop.name)
                                Text(directionDescription(for: stop))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: favourites.isFavourite(stop) ? "heart.fill" : "heart")
                                .foregroundStyle(favourites.isFavourite(stop) ? Color.red : Color.secondary)
                                .accessibilityHidden(true)
                        }
                        .contentShape(Rectangle())
                    }
                    .contextMenu {
                        Button(favourites.isFavourite(stop) ? "Remove Favourite" : "Add Favourite") {
                            favourites.toggle(stop)
                        }
                    }
                }
                .onDelete { offsets in
                    var current = orderedStops(from: favourites.favouriteStops)
                    let removed = offsets.map { current[$0] }
                    // Toggle off removed stops
                    for stop in removed { if favourites.isFavourite(stop) { favourites.toggle(stop) } }
                    // Persist remaining order
                    current.removeAll { removed.contains($0) }
                    saveOrder(for: current)
                }
                .onMove { indices, newOffset in
                    var current = orderedStops(from: favourites.favouriteStops)
                    current.move(fromOffsets: indices, toOffset: newOffset)
                    saveOrder(for: current)
                }
            }
        }
        .navigationTitle("Favourites")
        .onAppear {
            if favouritesOrderRaw.isEmpty {
                saveOrder(for: favourites.favouriteStops)
            } else {
                // Ensure we include any newly added favourites not yet in the stored order
                let current = orderedStops(from: favourites.favouriteStops)
                saveOrder(for: current)
            }
        }
    }

    private func directionDescription(for stop: BusStop) -> String {
        var parts: [String] = []
        if StopsData.toCity.contains(stop) { parts.append("To City") }
        if StopsData.toSwords.contains(stop) { parts.append("To Swords") }
        return parts.isEmpty ? "Unknown" : parts.joined(separator: " / ")
    }
}

// Removed private extension FavouritesStore with reorderFavourites(from:to:)

#Preview {
    ContentView()
        .environmentObject(FavouritesStore())
}

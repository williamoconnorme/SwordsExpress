import Foundation
import SwiftUI
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
final class FavouritesStore: ObservableObject {
    @Published private(set) var favouriteStopIDs: Set<Int>
    private let storageKey = SharedConstants.favouriteStopIDsKey
    private let defaults: UserDefaults

    /// Use shared app-group defaults so the widget extension can read favourites.
    /// Falls back to standard defaults if the app group is not (yet) configured.
    init(userDefaults: UserDefaults? = nil) {
        // Avoid referencing SharedConstants in a default argument (actor crossing); compute here instead.
        let resolvedDefaults = userDefaults ?? UserDefaults(suiteName: SharedConstants.appGroupIdentifier) ?? .standard
        self.defaults = resolvedDefaults
        if let saved = defaults.array(forKey: storageKey) as? [Int] {
            favouriteStopIDs = Set(saved)
        } else {
            favouriteStopIDs = []
        }
    }

    private func persist() {
        defaults.set(Array(favouriteStopIDs), forKey: storageKey)
    }

    func isFavourite(_ stop: BusStop) -> Bool { favouriteStopIDs.contains(stop.id) }

    func toggle(_ stop: BusStop) {
        if favouriteStopIDs.contains(stop.id) {
            favouriteStopIDs.remove(stop.id)
        } else {
            favouriteStopIDs.insert(stop.id)
        }
        persist()
        objectWillChange.send()
#if canImport(WidgetKit)
        // Trigger widget refresh so changes reflect promptly
        WidgetCenter.shared.reloadTimelines(ofKind: "LiveDepartures")
#endif
    }

    var favouriteStops: [BusStop] {
        let all = StopsData.toCity + StopsData.toSwords
        let dict = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        return favouriteStopIDs.compactMap { dict[$0] }.sorted { $0.name < $1.name }
    }
}

import Foundation
import SwiftUI
import Combine

@MainActor
final class FavouritesStore: ObservableObject {
    @Published private(set) var favouriteStopIDs: Set<Int>
    private let storageKey = "favouriteStopIDs"

    init() {
        if let saved = UserDefaults.standard.array(forKey: storageKey) as? [Int] {
            favouriteStopIDs = Set(saved)
        } else {
            favouriteStopIDs = []
        }
    }

    private func persist() {
        UserDefaults.standard.set(Array(favouriteStopIDs), forKey: storageKey)
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
    }

    var favouriteStops: [BusStop] {
        let all = StopsData.toCity + StopsData.toSwords
        let dict = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
        return favouriteStopIDs.compactMap { dict[$0] }.sorted { $0.name < $1.name }
    }
}

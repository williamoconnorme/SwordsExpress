//  SharedConstants.swift
//  SwordsExpress
//  Central place for cross-target constants (App + Widget Extension)
//
//  If you change the app group identifier here make sure to update it in
//  Xcode Signing & Capabilities for BOTH the main app target and the
//  LiveDepartures widget extension.

import Foundation

enum SharedConstants {
    // App Group used to share UserDefaults (favourites etc) with widgets
    // Ensure this matches the App Group you add in Signing & Capabilities.
    static let appGroupIdentifier = "group.me.williamoconnor.SwordsExpress"

    // UserDefaults key for favourite stop IDs (mirrors existing storageKey)
    static let favouriteStopIDsKey = "favouriteStopIDs"
}

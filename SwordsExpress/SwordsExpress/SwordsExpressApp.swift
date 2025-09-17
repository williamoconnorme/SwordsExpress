//
//  SwordsExpressApp.swift
//  SwordsExpress
//
//  Created by William O'Connor on 11/09/2025.
//

import SwiftUI
import SwiftData

@main
struct SwordsExpressApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    TimetableStore.load()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

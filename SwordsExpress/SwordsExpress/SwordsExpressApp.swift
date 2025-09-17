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

    @State private var pendingURL: URL? = nil
    @State private var favouritesDeepLinkTrigger: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.openFavouritesFromWidget, favouritesDeepLinkTrigger)
                .onChange(of: pendingURL) { _, newValue in
                    guard let url = newValue else { return }
                    if url.host == "favourites" || url.path == "/favourites" {
                        // Toggle the trigger to inform ContentView to show favourites tab
                        favouritesDeepLinkTrigger.toggle()
                    }
                }
                .onOpenURL { url in
                    pendingURL = url
                }
                .task { TimetableStore.load() }
        }
        .modelContainer(sharedModelContainer)
    }
}

// Environment key to signal opening favourites tab
private struct OpenFavouritesKey: EnvironmentKey { static let defaultValue: Bool = false }
extension EnvironmentValues { var openFavouritesFromWidget: Bool { get { self[OpenFavouritesKey.self] } set { self[OpenFavouritesKey.self] = newValue } } }

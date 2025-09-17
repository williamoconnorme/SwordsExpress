import SwiftUI

struct SettingsView: View {
    @Binding var showFavouritesTab: Bool

    var body: some View {
        Form {
            Section("Navigation") {
                Toggle(isOn: $showFavouritesTab) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show Favourites in Tabs")
                        Text("Hide the Favourites tab from the main navigation.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showFavouritesTab: .constant(true))
    }
}

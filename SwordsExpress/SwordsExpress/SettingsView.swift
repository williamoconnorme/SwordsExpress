import SwiftUI

struct SettingsView: View {
    @Binding var showFavouritesTab: Bool

    var body: some View {
        Form {
            Toggle("Show Favourites Tab", isOn: $showFavouritesTab)
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showFavouritesTab: .constant(true))
    }
}

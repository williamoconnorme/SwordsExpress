import SwiftUI
import UIKit
import CoreLocation

struct SettingsView: View {
    @Binding var showFavouritesTab: Bool
    @AppStorage("mapShowUserLocation") private var mapShowUserLocation: Bool = false
    @AppStorage("mapShowDirectionsButton") private var mapShowDirectionsButton: Bool = true
    @AppStorage("allowLowPowerOverride") private var allowLowPowerOverride: Bool = false
    @StateObject private var locationPermission = LocationPermissionManager()
    @Environment(\.openURL) private var openURL

    private var hasLocationPermission: Bool {
        switch locationPermission.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    var body: some View {
        Form {
            Toggle("Show Favourites Tab", isOn: $showFavouritesTab)
            Section("Map") {
                Toggle("Show My Location", isOn: $mapShowUserLocation)
                    .disabled(!hasLocationPermission)
                Toggle("Show Directions Button", isOn: $mapShowDirectionsButton)
                if !hasLocationPermission {
                    Text("Enable location access in Settings to show your position on the map.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Open Location Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }
            }
            Section("Power") {
                Toggle(isOn: $allowLowPowerOverride) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ignore Low Power Throttling")
                        Text("Keeps live updates fast while Low Power Mode is on.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if !hasLocationPermission { mapShowUserLocation = false }
        }
        .onChange(of: locationPermission.authorizationStatus) { _, _ in
            if !hasLocationPermission { mapShowUserLocation = false }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(showFavouritesTab: .constant(true))
    }
}

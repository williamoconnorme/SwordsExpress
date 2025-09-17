import SwiftUI

struct InformationView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Fares", destination: FaresView())
                }
                Section(header: Text("Contact Swords Express")) {
                    Button(action: {
                        if let url = URL(string: "mailto:feedback@swordsexpress.ie") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Email Us", systemImage: "envelope")
                    }
                    Button(action: {
                        if let url = URL(string: "tel://0035315292277") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Call Us", systemImage: "phone")
                    }
                }
                Section(header: Text("About this app")) {
                    NavigationLink("Disclaimer", destination: DisclaimerView())
                    Button(action: {
                        if let url = URL(string: "https://bsky.app/profile/williamoconnor.me") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Follow Developer on Blue Sky", systemImage: "link")
                    }
                }
                // App version at the bottom
                HStack {
                    let version = Bundle.main.releaseVersionNumber
                    let build = Bundle.main.buildVersionNumber
                    Text("Version \(version) (\(build))")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("App version \(version), build \(build)")
                }
                .listRowBackground(Color.clear)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Information")
        }
    }
}

// MARK: - Bundle Helpers
private extension Bundle {
    var releaseVersionNumber: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
    var buildVersionNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}

// MARK: - Disclaimer View
struct DisclaimerView: View {
    private var paragraphs: [String] {
        [
            "This unofficial Swords Express companion app was created by William O'Connor to provide quicker access to live bus information, routes and fares.",
            "It is not endorsed by, affiliated with, or maintained by Swords Express, Bus Eire, or any related operating company.",
            "All timetable, fares and operational data is sourced from publicly available information on the official Swords Express website or live service endpoints.",
            "While reasonable care is taken to present accurate information, no guarantee is made about correctness, availability or real‑time accuracy. Always verify critical travel decisions with official sources.",
            "By using this app you accept that the developer assumes no liability for missed services, incorrect data, indirect or consequential loss arising from its use.",
            "Suggestions or issues? You can reach out via the contact options in the Information tab."
        ]
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                ForEach(paragraphs, id: \.self) { text in
                    Text(text)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Divider().padding(.top, 8)
                Text("Version \(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 22)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 18, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 0.8)
            )
            .padding(.horizontal)
            .padding(.top, 12)
            .accessibilityElement(children: .contain)
        }
        .background(gradientBackground.ignoresSafeArea())
        .navigationTitle("Disclaimer")
        .toolbar { toolbarContent }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 30, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Important")
                        .font(.title2.weight(.semibold))
                    Text("Please read before relying on data")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Done") { dismiss() }
        }
    }

    private var gradientBackground: some View {
        LinearGradient(
            colors: [Color(.systemBackground), Color.brandPrimary.opacity(0.08)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}


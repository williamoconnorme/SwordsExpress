import SwiftUI

// MARK: - Models matching fares.json
struct FaresPayload: Codable {
    struct Metadata: Codable {
        let lastUpdated: String
        let currency: String
        let notes: [Note]
    }
    struct Note: Codable, Identifiable {
        var id: String { title }
        let title: String
        let body: String
    }
    struct FareTypes: Codable {
        let Cash: [String: PassengerCategory]
        let Leap: [String: PassengerCategory]
        let Taxsaver: [String: PassengerCategory]?
    }
    struct PassengerCategory: Codable {
        let groups: [FareGroup]?
        let information: String?
    }
    struct FareGroup: Codable, Identifiable {
        var id: String { name }
        let name: String
        let fares: [Fare]
    }
    struct Fare: Codable, Identifiable {
        var id: String { code }
        let code: String
        let label: String
        let price: Double
        let description: String?
    }

    let metadata: Metadata
    let fareTypes: FareTypes
}

// MARK: - View
struct FaresView: View {
    enum FareType: String, CaseIterable, Identifiable { case Cash, Leap, Taxsaver; var id: String { rawValue } }
    enum Passenger: String, CaseIterable, Identifiable { case Adult, Student, Child; var id: String { rawValue } }

    @State private var payload: FaresPayload?
    @State private var loadError: String?
    @State private var selectedFareType: FareType = .Cash
    @State private var selectedPassenger: Passenger = .Adult

    var body: some View {
        NavigationStack {
            Group {
                if let payload {
                    content(for: payload)
                } else if let loadError {
                    ScrollView { Text(loadError).foregroundStyle(.red).padding() }
                } else {
                    ProgressView("Loading fares...")
                }
            }
            .navigationTitle("Fares")
        }
        .task(load)
    }

    // MARK: - Content
    @ViewBuilder
    private func content(for payload: FaresPayload) -> some View {
        VStack(spacing: 12) {
            // Pickers
            HStack(spacing: 12) {
                Picker("Fare Type", selection: $selectedFareType) {
                    ForEach(availableFareTypes(in: payload), id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Passenger", selection: $selectedPassenger) {
                    ForEach(availablePassengers(for: selectedFareType, in: payload), id: \.self) { p in
                        Text(p.rawValue).tag(p)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)

            // List of fares
            List {
                let groups = groupsForSelection(in: payload)
                if groups.isEmpty {
                    Section {
                        Text("No fare data available for this selection.").foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(groups) { group in
                        Section(header: Text(group.name)) {
                            ForEach(group.fares) { fare in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(fare.label)
                                        Spacer()
                                        Text(formattedPrice(fare.price, currency: payload.metadata.currency)).bold()
                                    }
                                    if let desc = fare.description, !desc.isEmpty {
                                        Text(desc).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }

                // Passenger info
                if let info = passengerInfo(in: payload), !info.isEmpty {
                    Section("Information") {
                        Text(info)
                    }
                }

                // Notes
                if !payload.metadata.notes.isEmpty {
                    Section("Notes") {
                        ForEach(payload.metadata.notes) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title).font(.subheadline).bold()
                                Text(note.body).font(.footnote).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                        HStack {
                            Image(systemName: "calendar").foregroundStyle(.secondary)
                            Text("Last updated: \(payload.metadata.lastUpdated)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Helpers
    private func availableFareTypes(in payload: FaresPayload) -> [FareType] {
        var result: [FareType] = [.Cash, .Leap]
        if payload.fareTypes.Taxsaver != nil { result.append(.Taxsaver) }
        return result
    }

    private func availablePassengers(for type: FareType, in payload: FaresPayload) -> [Passenger] {
        switch type {
        case .Cash:
            return payload.fareTypes.Cash.keys.compactMap { Passenger(rawValue: $0) }.sorted { $0.rawValue < $1.rawValue }
        case .Leap:
            return payload.fareTypes.Leap.keys.compactMap { Passenger(rawValue: $0) }.sorted { $0.rawValue < $1.rawValue }
        case .Taxsaver:
            let keyArray: [String] = payload.fareTypes.Taxsaver.map { Array($0.keys) } ?? []
            let passengers = keyArray.compactMap { Passenger(rawValue: $0) }
            return passengers.isEmpty ? [.Adult] : passengers.sorted { $0.rawValue < $1.rawValue }
        }
    }

    private func groupsForSelection(in payload: FaresPayload) -> [FaresPayload.FareGroup] {
        let category: FaresPayload.PassengerCategory?
        switch selectedFareType {
        case .Cash:
            category = payload.fareTypes.Cash[selectedPassenger.rawValue]
        case .Leap:
            category = payload.fareTypes.Leap[selectedPassenger.rawValue]
        case .Taxsaver:
            category = payload.fareTypes.Taxsaver?[selectedPassenger.rawValue]
        }
        return category?.groups ?? []
    }

    private func passengerInfo(in payload: FaresPayload) -> String? {
        let category: FaresPayload.PassengerCategory?
        switch selectedFareType {
        case .Cash:
            category = payload.fareTypes.Cash[selectedPassenger.rawValue]
        case .Leap:
            category = payload.fareTypes.Leap[selectedPassenger.rawValue]
        case .Taxsaver:
            category = payload.fareTypes.Taxsaver?[selectedPassenger.rawValue]
        }
        return category?.information
    }

    private func formattedPrice(_ price: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        if let s = formatter.string(from: NSNumber(value: price)) { return s }
        return "\(currency) \(price)"
    }

    private func load() async {
        guard let url = Bundle.main.url(forResource: "fares", withExtension: "json") else {
            loadError = "fares.json not found."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(FaresPayload.self, from: data)
            await MainActor.run {
                self.payload = decoded
                // Clamp selections to available options
                if !availableFareTypes(in: decoded).contains(selectedFareType) {
                    selectedFareType = .Cash
                }
                let passengers = availablePassengers(for: selectedFareType, in: decoded)
                if !passengers.contains(selectedPassenger) {
                    selectedPassenger = passengers.first ?? .Adult
                }
            }
        } catch {
            loadError = "Failed to load fares.json: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack { FaresView() }
}


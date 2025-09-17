import Foundation

func fetchNextBusTimes(direction: String, stop: String) async throws -> [String] {
    let urlString = "https://www.swordsexpress.com/api/nextBus/?direction=\(direction)&stop=\(stop)"
    guard let url = URL(string: urlString) else { throw URLError(.badURL) }
    print("[NextBus] Requesting times for stop='\(stop)' direction='\(direction)' URL=\(url.absoluteString)")
    let (data, _) = try await URLSession.shared.data(from: url)
    do {
        if let arr = try JSONSerialization.jsonObject(with: data) as? [String] {
            return arr
        } else if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // Sometimes wrapped like {"times":["HH:mm", ...]}
            if let times = dict["times"] as? [String] { return times }
            return []
        } else {
            return []
        }
    } catch {
        // Malformed / non-JSON (e.g., empty string or HTML) -> treat as no times
        return []
    }
}

func fetchTimetable(direction: String, stop: String) async throws -> [TimetableEntry] {
    let timetableURLString = "https://www.swordsexpress.com/api/timetable/?direction=\(direction)&stop=\(stop)"

    func parseTimetableData(_ data: Data) throws -> [TimetableEntry] {
        if let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            return arr.compactMap { dict in
                if let t = dict["time"] as? String, let r = dict["route"] as? String {
                    return TimetableEntry(time: t, route: r)
                } else if let t = dict["time"] as? String {
                    return TimetableEntry(time: t, route: "N/A")
                } else { return nil }
            }
        } else if let arr = try JSONSerialization.jsonObject(with: data) as? [String] {
            return arr.map { TimetableEntry(time: $0, route: "N/A") }
        } else { return [] }
    }

    if let url = URL(string: timetableURLString) {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let entries = try parseTimetableData(data)
            if !entries.isEmpty { return entries }
        } catch { /* fall through to nextBus fallback */ }
    }

    // Fallback
    let nextBusURLString = "https://www.swordsexpress.com/api/nextBus/?direction=\(direction)&stop=\(stop)"
    guard let nextURL = URL(string: nextBusURLString) else { throw URLError(.badURL) }
    do {
        let (data, _) = try await URLSession.shared.data(from: nextURL)
        if let arr = try JSONSerialization.jsonObject(with: data) as? [String] {
            return arr.map { TimetableEntry(time: $0, route: "N/A") }
        } else if let arr = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            let times = arr.compactMap { $0["time"] as? String }
            if !times.isEmpty { return times.map { TimetableEntry(time: $0, route: "N/A") } }
        }
        return []
    } catch {
        throw URLError(.cannotLoadFromNetwork)
    }
}

import Foundation

struct BusUpcomingTime: Identifiable, Hashable {
    let id: String
    let time: String          // Original HH:mm string
    let intervalDescription: String
    let minutes: Int          // Minutes from now (0 = now)
}

enum BusTimeFormatter {
    private static let tz = TimeZone(identifier: "Europe/Dublin") ?? .current

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone = tz
        return f
    }()

    /// Compute upcoming times with human readable relative intervals.
    /// - Parameters:
    ///   - times: Array of HH:mm strings (assumed same day, ascending).
    ///   - now: Reference date (defaults to current system time).
    ///   - pastGrace: Seconds tolerance for just-past entries to still show as "now".
    /// - Returns: Array of BusUpcomingTime
    static func upcomingTimes(from times: [String], now: Date = Date(), pastGrace: TimeInterval = 30) -> [BusUpcomingTime] {
        let calendar = Calendar(identifier: .gregorian)
        var results: [BusUpcomingTime] = []

        for t in times {
            guard let parsed = formatter.date(from: t) else { continue }
            // Build a date for today using parsed hour/minute in Dublin TZ
            var comps = calendar.dateComponents(in: tz, from: now)
            let hm = calendar.dateComponents([.hour, .minute], from: parsed)
            comps.hour = hm.hour
            comps.minute = hm.minute
            comps.second = 0
            guard let busDate = calendar.date(from: comps) else { continue }
            let interval = busDate.timeIntervalSince(now)
            // Skip if decisively in the past beyond grace window
            if interval < -pastGrace { continue }
            let minutes = Int(interval / 60)
            let description: String
            if minutes <= 0 {
                description = "now"
            } else if minutes < 60 {
                description = "in \(minutes) min"
            } else {
                let hours = minutes / 60
                let rem = minutes % 60
                description = rem == 0 ? "in \(hours) hr" : "in \(hours) hr \(rem) min"
            }
            results.append(BusUpcomingTime(id: t, time: t, intervalDescription: description, minutes: max(0, minutes)))
        }
        return results
    }
}

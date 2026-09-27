import Foundation

/// The user's UTC offset stored with each transaction (`local_offset`, a PostgreSQL `INTERVAL`).
nonisolated struct LocalOffset: Equatable, Sendable {
    let seconds: Int

    init(seconds: Int) {
        self.seconds = seconds
    }

    /// Parses an interval as PostgreSQL returns it (`"02:00:00"`, `"-05:30:00"`) or as clients send it (`"+02:00"`).
    init?(interval: String) {
        let pattern = /^([+-])?(\d{1,2}):(\d{2})(?::(\d{2}))?$/
        guard
            let match = interval.trimmingCharacters(in: .whitespaces).wholeMatch(of: pattern),
            let hours = Int(match.2),
            let minutes = Int(match.3)
        else { return nil }
        let magnitude = hours * 3600 + minutes * 60 + (match.4.flatMap { Int($0) } ?? 0)
        seconds = match.1 == "-" ? -magnitude : magnitude
    }

    /// The device's offset at `date`, to send as `p_local_offset`.
    static func current(at date: Date = .now, in timeZone: TimeZone = .current) -> LocalOffset {
        LocalOffset(seconds: timeZone.secondsFromGMT(for: date))
    }

    /// `"+02:00"`, `"-05:30"` — the format clients send to the backend.
    var intervalString: String {
        let magnitude = abs(seconds)
        let sign = seconds < 0 ? "-" : "+"
        return String(format: "%@%02d:%02d", sign, magnitude / 3600, magnitude % 3600 / 60)
    }

    /// A fixed-offset time zone for showing a transaction in the local time it happened (`GEN-12`).
    var timeZone: TimeZone {
        TimeZone(secondsFromGMT: seconds) ?? .gmt
    }
}

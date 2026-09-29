import Foundation

/// A calendar month without a time zone, to match the server's months with the device's.
nonisolated struct YearMonth: Hashable, Sendable {
    let year: Int
    /// 1…12.
    let month: Int

    init(year: Int, month: Int) {
        self.year = year
        self.month = month
    }

    init(_ date: Date, in calendar: Calendar) {
        let components = calendar.dateComponents([.year, .month], from: date)
        self.init(year: components.year ?? 0, month: components.month ?? 1)
    }

    /// The month of a `DATE` or timestamp text, `2026-09-01…`, read without any time zone.
    init?(isoDate text: String) {
        let parts = text.prefix(10).split(separator: "-")
        guard parts.count == 3, let year = Int(parts[0]), let month = Int(parts[1]), (1...12).contains(month) else {
            return nil
        }
        self.init(year: year, month: month)
    }

    /// The month's first day as a `DATE` parameter, `2026-09-01`. No time zone is involved: it is the user's local
    /// calendar month, which the server compares with `transacted_at + local_offset` (`GEN-12`).
    var firstDayParameter: String {
        String(format: "%04d-%02d-01", year, month)
    }

    func adding(months: Int) -> YearMonth {
        let index = year * 12 + (month - 1) + months
        return YearMonth(year: index / 12, month: index % 12 + 1)
    }

    /// Midnight of the month's first day in `calendar`.
    func start(in calendar: Calendar) -> Date? {
        calendar.date(from: DateComponents(year: year, month: month, day: 1))
    }
}

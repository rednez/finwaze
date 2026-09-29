import Foundation

nonisolated extension Date {
    /// `TIMESTAMPTZ` as PostgREST returns it: `2026-09-27T10:15:00+00:00`, with or without fractional seconds.
    init?(timestamptz text: String) {
        guard
            let date = (try? Date.ISO8601FormatStyle(includingFractionalSeconds: true).parse(text))
                ?? (try? Date.ISO8601FormatStyle().parse(text))
        else { return nil }
        self = date
    }

    /// A `DATE` as a calendar day: midnight in `timeZone`, so it formats as the same day on this device.
    init?(isoDate text: String, timeZone: TimeZone = .current) {
        guard let date = try? Date.ISO8601FormatStyle(timeZone: timeZone).year().month().day().parse(text) else {
            return nil
        }
        self = date
    }

    /// `YYYY-MM-DD` in `timeZone`, the format of `DATE` parameters sent to the backend.
    func isoDateString(in timeZone: TimeZone = .current) -> String {
        formatted(Date.ISO8601FormatStyle(timeZone: timeZone).year().month().day())
    }

    /// A `TIMESTAMPTZ` parameter in UTC with the `Z` designator: without it Postgres would read the time in the
    /// session's time zone.
    var timestamptzString: String {
        Date.ISO8601FormatStyle(includingFractionalSeconds: true, timeZone: .gmt).format(self)
    }

    /// Date and time of a transaction in the local time it happened, not the device's (`GEN-12`, `GEN-18`).
    func formattedTransactionDate(offset: LocalOffset, locale: Locale = .current) -> String {
        formatted(Date.FormatStyle(date: .abbreviated, time: .shortened, locale: locale, timeZone: offset.timeZone))
    }

    /// "27 Sep, 14:05" — day, short month and time in the local time of a transaction, for a row outside a day card
    /// (`GEN-12`, `GEN-18`).
    func formattedTransactionShortDate(offset: LocalOffset, locale: Locale = .current) -> String {
        formatted(Date.FormatStyle(locale: locale, timeZone: offset.timeZone).day().month(.abbreviated).hour().minute())
    }

    /// Time of a transaction in the local time it happened, e.g. "14:05" (`GEN-12`).
    func formattedTransactionTime(offset: LocalOffset, locale: Locale = .current) -> String {
        formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: locale, timeZone: offset.timeZone))
    }

    /// "Friday, 25 September" in the local time of a transaction (`GEN-12`, `GEN-18`).
    func formattedTransactionDay(offset: LocalOffset, locale: Locale = .current) -> String {
        formatted(Date.FormatStyle(locale: locale, timeZone: offset.timeZone).weekday(.wide).day().month(.wide))
    }

    /// "September 2026" in the interface language (`GEN-14`, `GEN-18`).
    func formattedMonth(locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        formatted(Date.FormatStyle(locale: locale, timeZone: timeZone).month(.wide).year())
    }
}

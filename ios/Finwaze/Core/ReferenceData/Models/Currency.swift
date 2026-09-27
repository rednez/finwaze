import Foundation

/// An entry of the full currency directory, e.g. "USD – US Dollar".
nonisolated struct Currency: Identifiable, Equatable, Hashable, Sendable {
    let id: Int64
    let code: String
    let name: String
    let countryName: String
}

nonisolated extension Currency {
    /// "USD – US Dollar", how a currency is shown wherever it is picked (`ONB-02`, `ACC-07`).
    var displayName: String {
        "\(code) – \(name)"
    }

    /// Whether the currency's code or name contains `query`, ignoring case and diacritics; an empty query matches all.
    func matches(_ query: String) -> Bool {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        return [code, name].contains { $0.localizedStandardContains(query) }
    }
}

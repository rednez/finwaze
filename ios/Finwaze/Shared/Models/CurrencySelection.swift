import Foundation

/// Which currency a filter shows (`DASH-01`, `GEN-11`): the one picked there, else the primary currency, else the
/// first of the user's. One no account has any more falls back the same way.
nonisolated enum CurrencySelection {
    /// - Parameters:
    ///   - picked: The currency picked in the filter, `nil` until the user picks one.
    ///   - codes: The currencies of the user's accounts, in the order the filter lists them.
    ///   - primary: The primary currency (`DevicePreferences.primaryCurrencyCode`).
    static func currencyCode(picked: String?, among codes: [String], primary: String?) -> String? {
        if let picked, codes.contains(picked) { return picked }
        if let primary, codes.contains(primary) { return primary }
        return codes.first
    }
}

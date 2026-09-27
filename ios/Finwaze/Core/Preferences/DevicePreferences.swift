import Foundation
import Observation

/// Last choices on a new-transaction form, remembered separately for expenses and incomes (`TX-16`).
nonisolated struct TransactionFormDefaults: Codable, Equatable, Sendable {
    var accountID: Int64?
    var groupID: Int64?
    var categoryID: Int64?
    /// Purchase currency; used for expenses only.
    var currencyCode: String?
}

/// Per-user settings kept on this device until sign-out (`GEN-17`).
@Observable
final class DevicePreferences {
    private enum Key {
        static let ownerUserID = "preferences.ownerUserID"
        static let primaryCurrencyCode = "preferences.primaryCurrencyCode"
        static let expenseDefaults = "preferences.expenseDefaults"
        static let incomeDefaults = "preferences.incomeDefaults"

        static let all = [ownerUserID, primaryCurrencyCode, expenseDefaults, incomeDefaults]
    }

    @ObservationIgnored private let defaults: UserDefaults

    /// Currency chosen on the Dashboard; other sections start from it (`DASH-01`, `NAV-11`).
    var primaryCurrencyCode: String? {
        didSet { defaults.set(primaryCurrencyCode, forKey: Key.primaryCurrencyCode) }
    }

    var expenseDefaults: TransactionFormDefaults? {
        didSet { store(expenseDefaults, forKey: Key.expenseDefaults) }
    }

    var incomeDefaults: TransactionFormDefaults? {
        didSet { store(incomeDefaults, forKey: Key.incomeDefaults) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        primaryCurrencyCode = defaults.string(forKey: Key.primaryCurrencyCode)
        expenseDefaults = Self.load(from: defaults, forKey: Key.expenseDefaults)
        incomeDefaults = Self.load(from: defaults, forKey: Key.incomeDefaults)
    }

    /// Keeps the settings only if they belong to `userID`; otherwise starts from scratch.
    /// Covers a session that ended without an explicit sign-out (e.g. rejected by the server).
    func prepare(for userID: UUID) {
        guard defaults.string(forKey: Key.ownerUserID) != userID.uuidString else { return }
        clear()
        defaults.set(userID.uuidString, forKey: Key.ownerUserID)
    }

    func clear() {
        Key.all.forEach(defaults.removeObject(forKey:))
        primaryCurrencyCode = nil
        expenseDefaults = nil
        incomeDefaults = nil
    }

    private func store(_ value: TransactionFormDefaults?, forKey key: String) {
        guard let value, let data = try? JSONEncoder().encode(value) else {
            defaults.removeObject(forKey: key)
            return
        }
        defaults.set(data, forKey: key)
    }

    private static func load(from defaults: UserDefaults, forKey key: String) -> TransactionFormDefaults? {
        defaults.data(forKey: key).flatMap { try? JSONDecoder().decode(TransactionFormDefaults.self, from: $0) }
    }
}

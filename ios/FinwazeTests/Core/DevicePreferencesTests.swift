import Foundation
import Testing
@testable import Finwaze

@MainActor
struct DevicePreferencesTests {
    private let defaults = makeTestDefaults()

    @Test func persistsAcrossInstances() {
        let preferences = DevicePreferences(defaults: defaults)
        preferences.primaryCurrencyCode = "EUR"
        preferences.expenseDefaults = TransactionFormDefaults(accountID: 1, groupID: 2, categoryID: 3, currencyCode: "USD")

        let reloaded = DevicePreferences(defaults: defaults)

        #expect(reloaded.primaryCurrencyCode == "EUR")
        #expect(reloaded.expenseDefaults?.currencyCode == "USD")
        #expect(reloaded.incomeDefaults == nil)
    }

    @Test func keepsSettingsForTheSameUser() {
        let user = UUID()
        let preferences = DevicePreferences(defaults: defaults)
        preferences.prepare(for: user)
        preferences.primaryCurrencyCode = "EUR"

        preferences.prepare(for: user)

        #expect(preferences.primaryCurrencyCode == "EUR")
    }

    @Test func clearsSettingsOfAnotherUser() {
        let preferences = DevicePreferences(defaults: defaults)
        preferences.prepare(for: UUID())
        preferences.primaryCurrencyCode = "EUR"

        preferences.prepare(for: UUID())

        #expect(preferences.primaryCurrencyCode == nil)
        #expect(DevicePreferences(defaults: defaults).primaryCurrencyCode == nil)
    }

    @Test func clearRemovesEverything() {
        let preferences = DevicePreferences(defaults: defaults)
        preferences.primaryCurrencyCode = "EUR"
        preferences.incomeDefaults = TransactionFormDefaults(accountID: 1)

        preferences.clear()

        let reloaded = DevicePreferences(defaults: defaults)
        #expect(reloaded.primaryCurrencyCode == nil)
        #expect(reloaded.incomeDefaults == nil)
    }
}

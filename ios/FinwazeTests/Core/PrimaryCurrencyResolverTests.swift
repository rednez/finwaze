import Testing
@testable import Finwaze

struct PrimaryCurrencyResolverTests {
    private let accounts = [
        Account(id: 1, name: "Cash", currencyCode: "UAH"),
        Account(id: 2, name: "Card", currencyCode: "EUR"),
    ]

    @Test func keepsStoredCurrencyOfAnAccount() {
        #expect(PrimaryCurrencyResolver.resolve(stored: "EUR", accounts: accounts) == "EUR")
    }

    @Test func fallsBackToFirstAccount() {
        #expect(PrimaryCurrencyResolver.resolve(stored: nil, accounts: accounts) == "UAH")
        #expect(PrimaryCurrencyResolver.resolve(stored: "USD", accounts: accounts) == "UAH")
    }

    @Test func isNilWithoutAccounts() {
        #expect(PrimaryCurrencyResolver.resolve(stored: "EUR", accounts: []) == nil)
    }
}

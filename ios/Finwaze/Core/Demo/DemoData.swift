import Foundation

/// Local demo data, the same as the web client's (`src/app/core/services/demo-mode/demo-data.ts`).
nonisolated enum DemoData {
    /// Fixed identity of the demo "user", so device preferences survive relaunches in demo mode.
    static let userID = UUID(uuidString: "00000000-0000-0000-0000-00000000DE70")!

    static let accounts = [
        Account(id: 1, name: "Main Card", currencyCode: "USD"),
        Account(id: 2, name: "Cash", currencyCode: "UAH"),
        Account(id: 3, name: "Savings", currencyCode: "EUR"),
    ]

    static let currencies = [
        Currency(id: 1, code: "USD", name: "US Dollar", countryName: "United States"),
        Currency(id: 2, code: "UAH", name: "Ukrainian Hryvnia", countryName: "Ukraine"),
        Currency(id: 3, code: "EUR", name: "Euro", countryName: "European Union"),
    ]

    static let groups = [
        CategoryGroup(id: 1, name: "Food", transactionType: .expense, color: nil),
        CategoryGroup(id: 2, name: "Transport", transactionType: .expense, color: nil),
        CategoryGroup(id: 3, name: "Entertainment", transactionType: .expense, color: nil),
        CategoryGroup(id: 4, name: "Housing", transactionType: .expense, color: nil),
        CategoryGroup(id: 5, name: "Salary", transactionType: .income, color: nil),
    ]

    static let categories = [
        Category(id: 1, name: "Groceries", groupID: 1, color: nil),
        Category(id: 2, name: "Restaurants", groupID: 1, color: nil),
        Category(id: 3, name: "Taxi", groupID: 2, color: nil),
        Category(id: 4, name: "Public Transport", groupID: 2, color: nil),
        Category(id: 5, name: "Cinema", groupID: 3, color: nil),
        Category(id: 6, name: "Subscriptions", groupID: 3, color: nil),
        Category(id: 7, name: "Rent", groupID: 4, color: nil),
        Category(id: 8, name: "Monthly Paycheck", groupID: 5, color: nil),
    ]
}

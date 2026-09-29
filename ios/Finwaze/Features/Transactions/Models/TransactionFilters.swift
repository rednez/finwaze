import Foundation

/// What the transactions list asks the server for.
nonisolated struct TransactionQuery: Equatable, Sendable {
    let month: YearMonth
    let type: TransactionType?
    /// `nil` means any category.
    let categoryIDs: [Int64]?
    let currencyCode: String?
    let accountID: Int64?
}

/// The list's filters (`TX-03`) with the rules that tie them together (`TX-04`).
nonisolated struct TransactionFilters: Equatable, Sendable {
    /// The selected month (`GEN-14`).
    private(set) var month: YearMonth
    var type: TransactionType?
    /// Purchase currency; changing it resets the account (`TX-04`).
    var currencyCode: String? {
        didSet { if currencyCode != oldValue { accountID = nil } }
    }
    var accountID: Int64?
    /// Changing the group resets the category (`TX-04`).
    var groupID: Int64? {
        didSet { if groupID != oldValue { categoryID = nil } }
    }
    var categoryID: Int64?

    /// Starts on the current month with every other filter set to "All".
    init(now: Date = .now, calendar: Calendar = .current) {
        month = YearMonth(now, in: calendar)
    }

    /// How many filters besides the month are set to something other than "All".
    var activeCount: Int {
        [type != nil, currencyCode != nil, accountID != nil, groupID != nil, categoryID != nil].count(where: \.self)
    }

    /// Sets every filter back to "All"; the month stays.
    mutating func reset() {
        type = nil
        currencyCode = nil
        accountID = nil
        groupID = nil
        categoryID = nil
    }

    /// Moves the month by `months` (negative for earlier).
    mutating func shiftMonth(by months: Int) {
        month = month.adding(months: months)
    }

    /// The server query, or `nil` when nothing can match: a group without categories (`TX-04`).
    func query(categories: [Category]) -> TransactionQuery? {
        let categoryIDs: [Int64]?
        if let categoryID {
            categoryIDs = [categoryID]
        } else if let groupID {
            // A group without a category means every category of the group (`TX-04`).
            let ids = categories.filter { $0.groupID == groupID }.map(\.id)
            // The server reads an empty list as "any category", so answer "nothing" here.
            guard !ids.isEmpty else { return nil }
            categoryIDs = ids
        } else {
            categoryIDs = nil
        }
        return TransactionQuery(
            month: month,
            type: type,
            categoryIDs: categoryIDs,
            currencyCode: currencyCode,
            accountID: accountID
        )
    }
}

import Foundation
import Observation

/// The expense/income form, shared by "New transaction" and "Edit transaction" (`TX-10`, `TX-13…16`, `TX-20…24`,
/// `TX-30`, `TX-40`).
@Observable
final class TransactionFormViewModel {
    /// Creating a new transaction, or editing an existing one — fixed for the life of the form (`TX-40`).
    enum Mode: Equatable {
        case create
        case edit(Transaction)
    }

    enum AmountIssue: Equatable {
        case input(PositiveAmountInput.Issue)
        /// The purchase amount equals the charged amount (`TX-22`); shown under the purchase field.
        case equalsChargedAmount
        /// The charged amount equals the purchase amount (`TX-22`); shown under the charged field.
        case equalsExpenseAmount
    }

    enum CommentIssue: Equatable {
        case tooLong
    }

    static let commentLimit = 100

    let mode: Mode

    /// Expense or income; an expense by default (`TX-10`). Fixed while editing (`TX-40`). Switching fills the form
    /// with the choices remembered for the other type (`TX-16`).
    var type: TransactionType {
        didSet {
            guard type != oldValue, mode == .create else { return }
            applyRememberedChoices()
        }
    }

    /// Resets the purchase currency to the new account's when it changes (`TX-21`).
    var account: Account? {
        didSet {
            guard account != oldValue else { return }
            purchaseCurrencyCode = account?.currencyCode
        }
    }

    var amountText = ""
    /// The purchase currency for an expense (`TX-21`); always the account's for an income (`TX-30`). A state of its
    /// own, not derived from `account`, so it can differ from it.
    var purchaseCurrencyCode: String? {
        didSet {
            // The field appears empty when it appears through a change, not when it is filled from a saved
            // transaction — the caller sets it again afterwards in that case (`TX-22`).
            guard purchaseCurrencyCode != oldValue else { return }
            chargedAmountText = ""
        }
    }

    /// "Charged from account", shown only for a foreign-currency expense (`TX-22`).
    var chargedAmountText = ""
    var category: Category?
    /// "Now" by default (`TX-13`); the transaction's own moment while editing.
    var transactedAt: Date
    var comment = ""
    /// The server's explanation of a failed save; the entered data stays in the form (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false
    /// The transaction being edited no longer exists — found out while saving (`TX-42`).
    private(set) var isNotFound = false

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    private let repository: any TransactionsRepository
    /// Runs after the transaction is saved, while the button still shows its spinner.
    private let onSaved: () async -> Void

    init(
        mode: Mode = .create,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        repository: any TransactionsRepository,
        now: Date = .now,
        onSaved: @escaping () async -> Void
    ) {
        self.mode = mode
        self.referenceData = referenceData
        self.preferences = preferences
        self.repository = repository
        self.onSaved = onSaved

        switch mode {
        case .create:
            type = .expense
            transactedAt = now
            applyRememberedChoices()

        case .edit(let transaction):
            type = transaction.type
            account = referenceData.accounts.first { $0.id == transaction.accountID }
            category = referenceData.categories.first { $0.id == transaction.category.id }
            transactedAt = transaction.transactedAt
            comment = transaction.comment ?? ""
            amountText = Self.text(for: abs(transaction.transactionAmount))
            // Set after `account`, which would otherwise reset it to the account's own currency.
            purchaseCurrencyCode = transaction.transactionCurrencyCode
            // Set last: both `account` and `purchaseCurrencyCode` above clear it as they are assigned.
            chargedAmountText = transaction.isForeignCurrency ? Self.text(for: abs(transaction.chargedAmount)) : ""
        }
    }

    // MARK: Options

    var accounts: [Account] {
        referenceData.accounts
    }

    /// Currencies of the user's accounts, to choose the purchase currency from (`GEN-11`, `TX-21`).
    var purchaseCurrencyCodes: [String] {
        referenceData.accountCurrencyCodes
    }

    /// The charged amount field shows only for a foreign-currency expense (`TX-22`, `TX-30`).
    var showsChargedAmount: Bool {
        type == .expense && account != nil && purchaseCurrencyCode != nil && purchaseCurrencyCode != account?.currencyCode
    }

    /// Charged ÷ purchase amount while both parse (`GEN-10`).
    var exchangeRate: Decimal? {
        guard showsChargedAmount, let amount = parsedAmount, amount != 0, let charged = parsedChargedAmount else {
            return nil
        }
        return charged / amount
    }

    /// "1 EUR = 43,1250 UAH", 2 to 4 decimal places, in the interface language (`GEN-10`).
    var exchangeRateHint: String? {
        guard let rate = exchangeRate, let purchaseCurrencyCode, let accountCurrencyCode = account?.currencyCode else {
            return nil
        }
        return rate.formattedExchangeRate(from: purchaseCurrencyCode, to: accountCurrencyCode)
    }

    /// The group of the selected category, shown with it in the category field (`TX-11`).
    var categoryGroup: CategoryGroup? {
        category.flatMap { category in referenceData.groups.first { $0.id == category.groupID } }
    }

    /// The time zone the date field shows and edits in: the device's for a new transaction, the transaction's own
    /// while editing, even if it differs from the device's (`GEN-12`).
    var timeZone: TimeZone {
        switch mode {
        case .create: .current
        case .edit(let transaction): transaction.localOffset.timeZone
        }
    }

    // MARK: Validation (GEN-21)

    var accountIssue: RequiredIssue? {
        showsValidation && account == nil ? .required : nil
    }

    var categoryIssue: RequiredIssue? {
        showsValidation && category == nil ? .required : nil
    }

    var amountIssue: AmountIssue? {
        guard showsValidation else { return nil }
        if case .failure(let issue) = PositiveAmountInput.parse(amountText) { return .input(issue) }
        if showsChargedAmount, let amount = parsedAmount, let charged = parsedChargedAmount, amount == charged {
            return .equalsChargedAmount
        }
        return nil
    }

    var chargedAmountIssue: AmountIssue? {
        guard showsValidation, showsChargedAmount else { return nil }
        if case .failure(let issue) = PositiveAmountInput.parse(chargedAmountText) { return .input(issue) }
        if let amount = parsedAmount, let charged = parsedChargedAmount, amount == charged {
            return .equalsExpenseAmount
        }
        return nil
    }

    var commentIssue: CommentIssue? {
        showsValidation && trimmedComment.count > Self.commentLimit ? .tooLong : nil
    }

    // MARK: Submit

    /// Creates or saves the transaction; `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        isNotFound = false
        guard
            !isSubmitting,
            accountIssue == nil, categoryIssue == nil, commentIssue == nil,
            amountIssue == nil, chargedAmountIssue == nil,
            let account, let category,
            let amount = parsedAmount,
            let purchaseCurrencyCode,
            let currency = referenceData.currencies.first(where: { $0.code == purchaseCurrencyCode })
        else { return false }

        let chargedAmount: Decimal
        if showsChargedAmount {
            guard let value = parsedChargedAmount else { return false }
            chargedAmount = value
        } else {
            chargedAmount = amount
        }

        isSubmitting = true
        defer { isSubmitting = false }

        switch mode {
        case .create:
            let transaction = NewTransaction(
                type: type,
                transactedAt: transactedAt,
                // The offset when the transaction happened, not now: they differ across a daylight saving change.
                localOffset: LocalOffset.current(at: transactedAt),
                accountID: account.id,
                categoryID: category.id,
                transactionAmount: amount,
                transactionCurrencyID: currency.id,
                chargedAmount: chargedAmount,
                comment: trimmedComment.isEmpty ? nil : trimmedComment
            )
            do {
                try await repository.create(transaction)
            } catch {
                failure = error.localizedDescription
                return false
            }
            rememberChoices(account: account, category: category)
            await onSaved()
            return true

        case .edit(let original):
            let update = TransactionUpdate(
                transactedAt: transactedAt,
                localOffset: original.localOffset,
                accountID: account.id,
                categoryID: category.id,
                transactionAmount: amount,
                transactionCurrencyID: currency.id,
                chargedAmount: chargedAmount,
                comment: trimmedComment.isEmpty ? nil : trimmedComment
            )
            do {
                guard try await repository.update(id: original.id, update) else {
                    isNotFound = true
                    return false
                }
            } catch {
                failure = error.localizedDescription
                return false
            }
            await onSaved()
            return true
        }
    }

    // MARK: Remembered choices (TX-16, GEN-17)

    private var rememberedChoices: TransactionFormDefaults? {
        get { type == .income ? preferences.incomeDefaults : preferences.expenseDefaults }
        set {
            if type == .income {
                preferences.incomeDefaults = newValue
            } else {
                preferences.expenseDefaults = newValue
            }
        }
    }

    /// Fills the account, category and purchase currency last used for this type. Choices that no longer exist are
    /// skipped; the account entered so far stays when nothing is remembered. Only for a new transaction (`TX-40`).
    private func applyRememberedChoices() {
        let remembered = rememberedChoices
        if let accountID = remembered?.accountID, let match = accounts.first(where: { $0.id == accountID }) {
            account = match
        }
        category = remembered?.categoryID.flatMap { categoryID in
            referenceData.categories.first { $0.id == categoryID && isOfCurrentType($0) }
        }
        if let currencyCode = remembered?.currencyCode, purchaseCurrencyCodes.contains(currencyCode) {
            purchaseCurrencyCode = currencyCode
        }
    }

    private func rememberChoices(account: Account, category: Category) {
        rememberedChoices = TransactionFormDefaults(
            accountID: account.id,
            groupID: category.groupID,
            categoryID: category.id,
            currencyCode: type == .expense ? purchaseCurrencyCode : nil
        )
    }

    private func isOfCurrentType(_ category: Category) -> Bool {
        referenceData.groups.contains { $0.id == category.groupID && $0.transactionType == type }
    }

    private var trimmedComment: String {
        comment.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedAmount: Decimal? {
        try? PositiveAmountInput.parse(amountText).get()
    }

    private var parsedChargedAmount: Decimal? {
        try? PositiveAmountInput.parse(chargedAmountText).get()
    }

    /// A plain decimal string a user could type, e.g. `"250.5"` — for filling `amountText`/`chargedAmountText` from
    /// a saved transaction.
    private static func text(for amount: Decimal) -> String {
        "\(amount)"
    }
}

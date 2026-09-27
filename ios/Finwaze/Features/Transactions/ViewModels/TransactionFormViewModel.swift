import Foundation
import Observation

/// The new expense or income form (`TX-10`, `TX-13…16`, `TX-20`, `TX-21`, `TX-23`, `TX-24`, `TX-30`).
///
/// Stage 3 records one currency: the purchase currency is the account's and cannot be changed yet, so the charged
/// amount equals the entered one. The foreign-currency charge (`TX-22`) comes in stage 4.
@Observable
final class TransactionFormViewModel {
    enum RequiredIssue: Equatable {
        case required
    }

    enum AmountIssue: Equatable {
        case required
        /// Not a number, signed, zero or below.
        case notPositive
        /// More than two decimal places (`GEN-07`).
        case tooPrecise
    }

    enum CommentIssue: Equatable {
        case tooLong
    }

    static let commentLimit = 100

    /// Expense or income; an expense by default (`TX-10`). Switching fills the form with the choices remembered for
    /// the other type (`TX-16`).
    var type: TransactionType {
        didSet { if type != oldValue { applyRememberedChoices() } }
    }
    var account: Account?
    var amountText = ""
    var category: Category?
    /// "Now" by default (`TX-13`).
    var transactedAt: Date
    var comment = ""
    /// The server's explanation of a failed create; the entered data stays in the form (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    private let repository: any TransactionsRepository
    /// Runs after the transaction is created, while the button still shows its spinner.
    private let onCreated: () async -> Void

    init(
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        repository: any TransactionsRepository,
        now: Date = .now,
        onCreated: @escaping () async -> Void
    ) {
        self.referenceData = referenceData
        self.preferences = preferences
        self.repository = repository
        self.onCreated = onCreated
        type = .expense
        transactedAt = now
        applyRememberedChoices()
    }

    // MARK: Options

    var accounts: [Account] {
        referenceData.accounts
    }

    /// Always the account's currency until stage 4 lets the user pick another one (`TX-21`, `TX-23`).
    var purchaseCurrencyCode: String? {
        account?.currencyCode
    }

    /// The group of the selected category, shown with it in the category field (`TX-11`).
    var categoryGroup: CategoryGroup? {
        category.flatMap { category in referenceData.groups.first { $0.id == category.groupID } }
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
        return Self.validate(amountText).issue
    }

    var commentIssue: CommentIssue? {
        showsValidation && trimmedComment.count > Self.commentLimit ? .tooLong : nil
    }

    // MARK: Submit

    /// Creates the transaction; `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard
            !isSubmitting,
            accountIssue == nil, categoryIssue == nil, commentIssue == nil,
            let account, let category,
            case .valid(let amount) = Self.validate(amountText)
        else { return false }

        guard let currency = referenceData.currencies.first(where: { $0.code == account.currencyCode }) else {
            failure = String(localized: "error.generic.message")
            return false
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let transaction = NewTransaction(
            type: type,
            transactedAt: transactedAt,
            // The offset when the transaction happened, not now: they differ across a daylight saving change.
            localOffset: LocalOffset.current(at: transactedAt),
            accountID: account.id,
            categoryID: category.id,
            transactionAmount: amount,
            transactionCurrencyID: currency.id,
            chargedAmount: amount,
            comment: trimmedComment.isEmpty ? nil : trimmedComment
        )

        do {
            try await repository.create(transaction)
        } catch {
            failure = error.localizedDescription
            return false
        }

        rememberChoices(account: account, category: category)
        await onCreated()
        return true
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

    /// Fills the account and category last used for this type. Choices that no longer exist are skipped; the
    /// account entered so far stays when nothing is remembered.
    private func applyRememberedChoices() {
        let remembered = rememberedChoices
        if let accountID = remembered?.accountID, let match = accounts.first(where: { $0.id == accountID }) {
            account = match
        }
        category = remembered?.categoryID.flatMap { categoryID in
            referenceData.categories.first { $0.id == categoryID && isOfCurrentType($0) }
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

    private enum AmountValidation {
        case valid(Decimal)
        case invalid(AmountIssue)

        var issue: AmountIssue? {
            if case .invalid(let issue) = self { issue } else { nil }
        }
    }

    private static func validate(_ text: String) -> AmountValidation {
        switch DecimalInputParser.parse(text) {
        case .empty:
            .invalid(.required)
        case .invalid:
            .invalid(.notPositive)
        case .value(let value, let fractionDigits):
            if value <= 0 {
                .invalid(.notPositive)
            } else if fractionDigits > 2 {
                .invalid(.tooPrecise)
            } else {
                .valid(value)
            }
        }
    }
}

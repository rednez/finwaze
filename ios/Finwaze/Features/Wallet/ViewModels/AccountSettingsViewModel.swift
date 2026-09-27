import Foundation
import Observation

/// "Account settings" (`ACC-09…12`): loads one account fresh from the server, then renames it, changes its
/// currency while it has no transactions, sets its balance at a moment and deletes it.
@Observable
final class AccountSettingsViewModel {
    enum State: Equatable {
        case loading
        case loaded(AccountDetails)
        /// The account no longer exists: deleted elsewhere, or never visible under RLS.
        case notFound
        case failed
    }

    enum DateIssue: Equatable {
        /// The balance cannot be set at a moment in the future (`GEN-13`).
        case inFuture
    }

    let accountID: Int64
    private(set) var state: State = .loading

    var name = ""
    var currency: Currency?
    var balanceText = ""
    /// Off: the balance is set as of now. On: as of `balanceDate` (`ACC-09`).
    var usesBalanceDate = false
    var balanceDate: Date
    /// The server's explanation of a failed update; the entered data stays in the form (`GEN-19`).
    var failure: String?
    var deletionFailure: String?
    private(set) var isSubmitting = false
    private(set) var isDeleting = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let referenceData: ReferenceDataStore
    private let repository: any WalletRepository
    private let clock: () -> Date
    private let locale: Locale
    /// Runs after anything was saved, so the other screens show the new name, currency and balance (`GEN-26`).
    private let onChanged: () async -> Void
    private let onDeleted: () async -> Void

    init(
        accountID: Int64,
        referenceData: ReferenceDataStore,
        repository: any WalletRepository,
        clock: @escaping () -> Date = { .now },
        locale: Locale = .current,
        onChanged: @escaping () async -> Void,
        onDeleted: @escaping () async -> Void
    ) {
        self.accountID = accountID
        self.referenceData = referenceData
        self.repository = repository
        self.clock = clock
        self.locale = locale
        self.onChanged = onChanged
        self.onDeleted = onDeleted
        balanceDate = clock()
    }

    var details: AccountDetails? {
        if case .loaded(let details) = state { details } else { nil }
    }

    /// The full directory: the currency is set anew here (`GEN-11`).
    var currencies: [Currency] {
        referenceData.currencies
    }

    /// Only while the account has no transactions (`ACC-10`).
    var isCurrencyEditable: Bool {
        details?.canDelete == true
    }

    /// Only while the account has no transactions (`ACC-11`).
    var canDelete: Bool {
        details?.canDelete == true
    }

    /// The latest moment the date field accepts (`GEN-13`).
    var latestDate: Date {
        clock()
    }

    // MARK: Load

    /// Loads (or reloads) the account fresh from the server and fills the form with it.
    func load() async {
        state = .loading
        do {
            guard let details = try await repository.accountDetails(id: accountID) else {
                state = .notFound
                return
            }
            name = details.name
            currency = referenceData.currencies.first { $0.id == details.currencyID }
            balanceText = Self.text(for: details.balance, locale: locale)
            usesBalanceDate = false
            balanceDate = clock()
            showsValidation = false
            state = .loaded(details)
        } catch {
            state = .failed
        }
    }

    // MARK: Validation (GEN-21)

    var nameIssue: AccountFormViewModel.NameIssue? {
        guard showsValidation else { return nil }
        return AccountFormViewModel.nameLength.contains(trimmedName.count) ? nil : .length
    }

    var currencyIssue: AccountFormViewModel.CurrencyIssue? {
        showsValidation && currency == nil ? .required : nil
    }

    var balanceIssue: SignedAmountInput.Issue? {
        guard showsValidation, case .failure(let issue) = SignedAmountInput.parse(balanceText) else { return nil }
        return issue
    }

    var dateIssue: DateIssue? {
        showsValidation && usesBalanceDate && balanceDate > clock() ? .inFuture : nil
    }

    // MARK: Actions

    /// Saves the name and currency, then the balance — only if it changed, so an untouched balance adds no
    /// correction (`ACC-09`). `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard
            !isSubmitting,
            let details,
            nameIssue == nil, currencyIssue == nil, balanceIssue == nil, dateIssue == nil,
            let currency,
            let balance = try? SignedAmountInput.parse(balanceText).get()
        else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        let update = AccountUpdate(
            name: trimmedName,
            // Sent only when it may and did change (`ACC-10`).
            currencyID: isCurrencyEditable && currency.id != details.currencyID ? currency.id : nil
        )
        do {
            guard try await repository.updateAccount(id: accountID, update) else {
                state = .notFound
                return false
            }
        } catch {
            failure = error.localizedDescription
            return false
        }

        if balance != details.balance {
            let date = usesBalanceDate ? balanceDate : clock()
            let adjustment = BalanceAdjustment(
                accountID: accountID,
                targetBalance: balance,
                balanceDate: date,
                localOffset: LocalOffset.current(at: date)
            )
            do {
                try await repository.adjustBalance(adjustment)
            } catch {
                failure = error.localizedDescription
                // The name and currency are already saved: the other screens should show them.
                await onChanged()
                return false
            }
        }

        await onChanged()
        return true
    }

    /// Deletes the account with its corrections (`ACC-11`); `true` on success.
    @discardableResult
    func delete() async -> Bool {
        guard canDelete, !isDeleting else { return false }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await repository.deleteAccount(id: accountID)
        } catch {
            deletionFailure = error.localizedDescription
            return false
        }
        await onDeleted()
        return true
    }

    /// The balance as the user would type it in the interface language, without grouping: `4101,10`, `-300`.
    private static func text(for balance: Decimal, locale: Locale) -> String {
        var value = balance
        var whole = Decimal()
        NSDecimalRound(&whole, &value, 0, .plain)
        let fraction = whole == balance ? 0 : 2
        return balance.formatted(.number.precision(.fractionLength(fraction)).grouping(.never).locale(locale))
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

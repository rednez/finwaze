import Foundation
import Observation

/// "Account settings" (`ACC-09…12`): shows the Wallet card's copy straight away and loads the account fresh from the
/// server, then renames it, changes its currency while it has no transactions, sets its balance at a moment and
/// deletes it.
@Observable
final class AccountSettingsViewModel {
    let accountID: Int64
    private(set) var state: DetailState<AccountDetails> = .loading

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

    /// With a `preview` from the Wallet card, the form is filled from it at once, so the zoom ends on the form rather
    /// than a spinner; `load()` then brings in the fresh details. Until then the account counts as having
    /// transactions, like most do: its currency stays locked and it cannot be deleted.
    init(
        accountID: Int64,
        preview: WalletAccount? = nil,
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
        if let preview, let currency = referenceData.currencies.first(where: { $0.code == preview.currencyCode }) {
            fill(with: AccountDetails(
                id: preview.id,
                name: preview.name,
                currencyID: currency.id,
                currencyCode: preview.currencyCode,
                balance: preview.balance,
                canDelete: false
            ))
        }
    }

    var details: AccountDetails? {
        state.value
    }

    /// The full directory: the currency is set anew here (`GEN-11`).
    var currencies: [Currency] {
        referenceData.currencies
    }

    /// Only while the account has no transactions (`ACC-10`), like deleting it.
    var isCurrencyEditable: Bool {
        canDelete
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

    /// Loads (or reloads) the account fresh from the server and fills the form with it. While the card's copy is
    /// shown, it stays on screen: the fields are refilled only if the name, currency or balance changed, and a failed
    /// request leaves it be, as saving goes to the server anyway.
    func load() async {
        let shown = details
        if shown == nil {
            state = .loading
        }
        do {
            guard let details = try await repository.accountDetails(id: accountID) else {
                state = .notFound
                return
            }
            if let shown, shown.sameFields(as: details) {
                state = .loaded(details)
            } else {
                fill(with: details)
            }
        } catch {
            if shown == nil {
                state = .failed
            }
        }
    }

    private func fill(with details: AccountDetails) {
        name = details.name
        currency = referenceData.currencies.first { $0.id == details.currencyID }
        balanceText = details.balance.inputText(locale: locale)
        usesBalanceDate = false
        balanceDate = clock()
        showsValidation = false
        state = .loaded(details)
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

    var dateIssue: FutureDateIssue? {
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

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension AccountDetails {
    /// The same values in the form's fields; `canDelete` aside, which only the server knows.
    func sameFields(as other: AccountDetails) -> Bool {
        name == other.name && currencyID == other.currencyID && balance == other.balance
    }
}

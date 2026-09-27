import Foundation
import Observation

/// "Transfer money" between two regular accounts (`TRF-01…05`). A different currency on the destination account asks
/// for the received amount (`TRF-03`).
@Observable
final class TransferFormViewModel {
    enum AccountIssue: Equatable {
        case required
    }

    enum DateIssue: Equatable {
        /// A transfer cannot be dated in the future (`GEN-13`).
        case inFuture
    }

    /// Changing the source clears the destination: it may be the same account, or no longer fit (`TRF-02`).
    var fromAccount: Account? {
        didSet {
            guard fromAccount != oldValue else { return }
            toAccount = nil
        }
    }

    /// The received amount field appears empty whenever the destination changes (`TRF-03`).
    var toAccount: Account? {
        didSet {
            guard toAccount != oldValue else { return }
            receivedAmountText = ""
        }
    }

    var sentAmountText = ""
    /// "Received amount", shown only when the accounts' currencies differ (`TRF-03`).
    var receivedAmountText = ""
    /// "Now" by default; never later than now (`GEN-13`).
    var transactedAt: Date
    /// The server's explanation of a failed transfer; the entered data stays in the form (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let referenceData: ReferenceDataStore
    private let repository: any TransfersRepository
    private let clock: () -> Date
    /// Runs after the transfer is made, while the button still shows its spinner.
    private let onSaved: () async -> Void

    init(
        referenceData: ReferenceDataStore,
        repository: any TransfersRepository,
        clock: @escaping () -> Date = { .now },
        onSaved: @escaping () async -> Void
    ) {
        self.referenceData = referenceData
        self.repository = repository
        self.clock = clock
        self.onSaved = onSaved
        transactedAt = clock()
    }

    // MARK: Options

    /// Regular accounts only: savings-goal accounts are not part of reference data (`TRF-04`).
    var accounts: [Account] {
        referenceData.accounts
    }

    /// Empty until a source is chosen, and never the source itself (`TRF-02`).
    var toAccounts: [Account] {
        guard let fromAccount else { return [] }
        return accounts.filter { $0.id != fromAccount.id }
    }

    /// With a single account there is nowhere to transfer to; the form explains it.
    var needsAnotherAccount: Bool {
        accounts.count < 2
    }

    /// The latest moment the date field accepts (`GEN-13`).
    var latestDate: Date {
        clock()
    }

    var showsReceivedAmount: Bool {
        guard let fromAccount, let toAccount else { return false }
        return fromAccount.currencyCode != toAccount.currencyCode
    }

    /// Received ÷ sent while both parse (`TRF-03`, `GEN-10`).
    var exchangeRate: Decimal? {
        guard showsReceivedAmount, let sent = parsedSentAmount, let received = parsedReceivedAmount else { return nil }
        return received / sent
    }

    /// "1 EUR = 43,0000 UAH" (`GEN-10`).
    var exchangeRateHint: String? {
        guard let rate = exchangeRate, let fromAccount, let toAccount else { return nil }
        return rate.formattedExchangeRate(from: fromAccount.currencyCode, to: toAccount.currencyCode, fractionLength: 4...4)
    }

    // MARK: Validation (GEN-21)

    var fromAccountIssue: AccountIssue? {
        showsValidation && fromAccount == nil ? .required : nil
    }

    var toAccountIssue: AccountIssue? {
        showsValidation && toAccount == nil ? .required : nil
    }

    var sentAmountIssue: PositiveAmountInput.Issue? {
        guard showsValidation, case .failure(let issue) = PositiveAmountInput.parse(sentAmountText) else { return nil }
        return issue
    }

    var receivedAmountIssue: PositiveAmountInput.Issue? {
        guard
            showsValidation, showsReceivedAmount,
            case .failure(let issue) = PositiveAmountInput.parse(receivedAmountText)
        else { return nil }
        return issue
    }

    var dateIssue: DateIssue? {
        showsValidation && transactedAt > clock() ? .inFuture : nil
    }

    // MARK: Submit

    /// Makes the transfer; `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard
            !isSubmitting,
            fromAccountIssue == nil, toAccountIssue == nil, sentAmountIssue == nil, receivedAmountIssue == nil,
            dateIssue == nil,
            let fromAccount, let toAccount,
            let sentAmount = parsedSentAmount
        else { return false }

        let receivedAmount: Decimal?
        if showsReceivedAmount {
            guard let value = parsedReceivedAmount else { return false }
            receivedAmount = value
        } else {
            // The same currency: the server receives exactly what was sent (`TRF-03`).
            receivedAmount = nil
        }

        let transfer = NewTransfer(
            fromAccountID: fromAccount.id,
            toAccountID: toAccount.id,
            fromAmount: sentAmount,
            toAmount: receivedAmount,
            transactedAt: transactedAt,
            // The offset when the transfer happened, not now: they differ across a daylight saving change.
            localOffset: LocalOffset.current(at: transactedAt)
        )

        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await repository.make(transfer)
        } catch {
            failure = error.localizedDescription
            return false
        }
        await onSaved()
        return true
    }

    private var parsedSentAmount: Decimal? {
        try? PositiveAmountInput.parse(sentAmountText).get()
    }

    private var parsedReceivedAmount: Decimal? {
        try? PositiveAmountInput.parse(receivedAmountText).get()
    }
}

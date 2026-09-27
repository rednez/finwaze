import Foundation
import Testing
@testable import Finwaze

@MainActor
struct TransferFormViewModelTests {
    private let usdCard = Account(id: 1, name: "Card", currencyCode: "USD")
    private let usdCash = Account(id: 2, name: "Cash USD", currencyCode: "USD")
    private let uahCash = Account(id: 3, name: "Cash UAH", currencyCode: "UAH")
    private let now = Date(timeIntervalSince1970: 1_790_500_500)
    private let repository = FakeTransfersRepository()

    private func makeViewModel(
        accounts: [Account]? = nil,
        onSaved: @escaping () async -> Void = {}
    ) async throws -> TransferFormViewModel {
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository(accounts: accounts ?? [usdCard, usdCash, uahCash]))
        let now = now
        return TransferFormViewModel(
            referenceData: referenceData,
            repository: repository,
            clock: { now },
            onSaved: onSaved
        )
    }

    @Test func startsEmptyNow() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.fromAccount == nil)
        #expect(viewModel.toAccount == nil)
        #expect(viewModel.transactedAt == now)
        #expect(!viewModel.showsReceivedAmount)
        #expect(!viewModel.needsAnotherAccount)
    }

    @Test func destinationsAreEmptyUntilASourceIsChosenAndExcludeIt() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.toAccounts.isEmpty)

        viewModel.fromAccount = usdCard

        #expect(viewModel.toAccounts == [usdCash, uahCash])
    }

    @Test func changingTheSourceClearsTheDestination() async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = usdCash

        viewModel.fromAccount = uahCash

        #expect(viewModel.toAccount == nil)
    }

    @Test func receivedAmountOnlyForDifferentCurrencies() async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard

        viewModel.toAccount = usdCash
        #expect(!viewModel.showsReceivedAmount)

        viewModel.toAccount = uahCash
        #expect(viewModel.showsReceivedAmount)
    }

    @Test func receivedAmountAppearsEmpty() async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = uahCash
        viewModel.receivedAmountText = "4150"

        viewModel.toAccount = usdCash
        viewModel.toAccount = uahCash

        #expect(viewModel.receivedAmountText.isEmpty)
    }

    @Test func singleAccountNeedsAnother() async throws {
        let viewModel = try await makeViewModel(accounts: [usdCard])

        viewModel.fromAccount = usdCard

        #expect(viewModel.needsAnotherAccount)
        #expect(viewModel.toAccounts.isEmpty)
    }

    @Test func exchangeRateIsReceivedOverSent() async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = uahCash
        viewModel.sentAmountText = "100"
        viewModel.receivedAmountText = "4300"

        #expect(viewModel.exchangeRate == 43)
        #expect(viewModel.exchangeRateHint?.hasPrefix("1 USD = 43") == true)
        #expect(viewModel.exchangeRateHint?.hasSuffix(" UAH") == true)
    }

    @Test func hidesErrorsUntilSubmit() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.fromAccountIssue == nil)
        #expect(viewModel.sentAmountIssue == nil)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.fromAccountIssue == .required)
        #expect(viewModel.toAccountIssue == .required)
        #expect(viewModel.sentAmountIssue == .required)
        #expect(repository.made.isEmpty)
    }

    @Test(arguments: [("0", PositiveAmountInput.Issue.notPositive), ("-5", .notPositive), ("1.005", .tooPrecise)])
    func rejectsInvalidAmounts(text: String, issue: PositiveAmountInput.Issue) async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = uahCash
        viewModel.sentAmountText = text
        viewModel.receivedAmountText = text

        #expect(await viewModel.submit() == false)

        #expect(viewModel.sentAmountIssue == issue)
        #expect(viewModel.receivedAmountIssue == issue)
    }

    @Test func requiresTheReceivedAmountForDifferentCurrencies() async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = uahCash
        viewModel.sentAmountText = "100"

        #expect(await viewModel.submit() == false)

        #expect(viewModel.receivedAmountIssue == .required)
    }

    @Test func rejectsADateInTheFuture() async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = usdCash
        viewModel.sentAmountText = "100"
        viewModel.transactedAt = now.addingTimeInterval(3600)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.dateIssue == .inFuture)
        #expect(repository.made.isEmpty)
    }

    @Test func sameCurrencyTransferLeavesTheReceivedAmountToTheServer() async throws {
        var saves = 0
        let viewModel = try await makeViewModel(onSaved: { saves += 1 })
        viewModel.fromAccount = usdCard
        viewModel.toAccount = usdCash
        viewModel.sentAmountText = "100,5"

        #expect(await viewModel.submit())

        let transfer = try #require(repository.made.first)
        #expect(transfer.fromAccountID == 1)
        #expect(transfer.toAccountID == 2)
        #expect(transfer.fromAmount == Decimal(string: "100.5"))
        #expect(transfer.toAmount == nil)
        #expect(transfer.transactedAt == now)
        #expect(transfer.localOffset == LocalOffset.current(at: now))
        #expect(saves == 1)
    }

    @Test func differentCurrencyTransferSendsBothAmounts() async throws {
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = uahCash
        viewModel.sentAmountText = "100"
        viewModel.receivedAmountText = "4150"

        #expect(await viewModel.submit())

        #expect(repository.made.first?.fromAmount == 100)
        #expect(repository.made.first?.toAmount == 4150)
    }

    @Test func failureKeepsTheEnteredData() async throws {
        repository.setMakeFails(true)
        let viewModel = try await makeViewModel()
        viewModel.fromAccount = usdCard
        viewModel.toAccount = usdCash
        viewModel.sentAmountText = "100"

        #expect(await viewModel.submit() == false)

        #expect(viewModel.failure == "duplicate key value")
        #expect(viewModel.fromAccount == usdCard)
        #expect(viewModel.toAccount == usdCash)
        #expect(viewModel.sentAmountText == "100")
        #expect(!viewModel.isSubmitting)
    }
}

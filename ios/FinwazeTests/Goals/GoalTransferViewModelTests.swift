import Foundation
import Testing
@testable import Finwaze

@MainActor
struct GoalTransferViewModelTests {
    private let usdCard = Account(id: 1, name: "Card", currencyCode: "USD")
    private let usdCash = Account(id: 2, name: "Cash", currencyCode: "USD")
    private let eurCard = Account(id: 3, name: "Euro card", currencyCode: "EUR")
    private let now = Date(timeIntervalSince1970: 1_790_500_500)
    private let transfers = FakeTransfersRepository()
    private let goal = SavingsGoal.fixture(id: 101, currencyCode: "USD", saved: 400)

    private func makeViewModel(
        _ direction: GoalTransferViewModel.Direction,
        accounts: [Account]? = nil,
        goal: SavingsGoal? = nil,
        onSaved: @escaping () async -> Void = {}
    ) async throws -> GoalTransferViewModel {
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository(accounts: accounts ?? [usdCard, usdCash, eurCard]))
        let now = now
        return GoalTransferViewModel(
            goal: goal ?? self.goal,
            direction: direction,
            referenceData: referenceData,
            repository: transfers,
            clock: { now },
            onSaved: onSaved
        )
    }

    @Test func offersOnlyAccountsInTheGoalsCurrency() async throws {
        let viewModel = try await makeViewModel(.deposit)

        #expect(viewModel.accounts == [usdCard, usdCash])
        #expect(viewModel.account == nil)
        #expect(!viewModel.needsAccount)
    }

    @Test func theOnlyAccountIsPickedAlready() async throws {
        let viewModel = try await makeViewModel(.deposit, accounts: [usdCard, eurCard])

        #expect(viewModel.account == usdCard)
    }

    @Test func noAccountInTheCurrencyIsExplained() async throws {
        let viewModel = try await makeViewModel(.deposit, accounts: [eurCard])

        #expect(viewModel.needsAccount)
        #expect(await !viewModel.submit())
        #expect(transfers.made.isEmpty)
    }

    @Test func depositMovesMoneyFromTheAccountIntoTheGoal() async throws {
        var saved = false
        let viewModel = try await makeViewModel(.deposit) { saved = true }
        viewModel.selectedAccount = usdCash
        viewModel.amountText = "5000"

        #expect(await viewModel.submit())

        let transfer = try #require(transfers.made.first)
        #expect(transfer.fromAccountID == usdCash.id)
        #expect(transfer.toAccountID == goal.id)
        #expect(transfer.fromAmount == 5000)
        #expect(transfer.toAmount == nil)
        #expect(transfer.transactedAt == now)
        #expect(saved)
    }

    @Test func withdrawalMovesMoneyFromTheGoalToTheAccount() async throws {
        let viewModel = try await makeViewModel(.withdraw)
        viewModel.selectedAccount = usdCard
        viewModel.amountText = "400"

        #expect(await viewModel.submit())

        let transfer = try #require(transfers.made.first)
        #expect(transfer.fromAccountID == goal.id)
        #expect(transfer.toAccountID == usdCard.id)
        #expect(transfer.fromAmount == 400)
    }

    @Test func cannotWithdrawMoreThanSaved() async throws {
        let viewModel = try await makeViewModel(.withdraw)
        viewModel.selectedAccount = usdCard
        viewModel.amountText = "400.01"

        #expect(await !viewModel.submit())

        #expect(viewModel.amountIssue == .exceedsSaved)
        #expect(transfers.made.isEmpty)
    }

    @Test func validatesTheFields() async throws {
        let viewModel = try await makeViewModel(.deposit)
        #expect(viewModel.amountIssue == nil)

        viewModel.transactedAt = now.addingTimeInterval(60)
        #expect(await !viewModel.submit())

        #expect(viewModel.accountIssue == .required)
        #expect(viewModel.amountIssue == .input(.required))
        #expect(viewModel.dateIssue == .inFuture)

        viewModel.amountText = "0"
        #expect(viewModel.amountIssue == .input(.notPositive))
    }

    @Test func failureKeepsTheForm() async throws {
        var saved = false
        let viewModel = try await makeViewModel(.deposit) { saved = true }
        viewModel.selectedAccount = usdCard
        viewModel.amountText = "10"
        transfers.setMakeFails(true)

        #expect(await !viewModel.submit())

        #expect(viewModel.failure == "duplicate key value")
        #expect(viewModel.amountText == "10")
        #expect(!saved)
    }
}

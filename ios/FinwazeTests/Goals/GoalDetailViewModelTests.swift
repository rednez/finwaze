import Foundation
import Testing
@testable import Finwaze

@MainActor
struct GoalDetailViewModelTests {
    private let repository = FakeGoalsRepository()
    private let transfers = FakeTransfersRepository()
    private let usdCard = Account(id: 1, name: "Card", currencyCode: "USD")
    private let eurCard = Account(id: 3, name: "Euro card", currencyCode: "EUR")
    private let now = Date(timeIntervalSince1970: 1_790_500_500)

    private func makeViewModel(
        _ goal: SavingsGoal?,
        onChanged: @escaping () async -> Void = {}
    ) async throws -> GoalDetailViewModel {
        if let goal { repository.setGoals([goal]) }
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository(accounts: [usdCard, eurCard]))
        let now = now
        return GoalDetailViewModel(
            goalID: goal?.id ?? 404,
            referenceData: referenceData,
            repository: repository,
            transfers: transfers,
            clock: { now },
            onChanged: onChanged
        )
    }

    // MARK: Loading (GOAL-26)

    @Test func loadsTheGoalIntoTheForm() async throws {
        let goal = SavingsGoal.fixture()
        let viewModel = try await makeViewModel(goal)

        await viewModel.load()

        #expect(viewModel.state == .loaded(goal))
        #expect(viewModel.form?.mode == .edit(goal))
    }

    @Test func missingGoalIsNotFound() async throws {
        let viewModel = try await makeViewModel(nil)

        await viewModel.load()

        #expect(viewModel.state == .notFound)
        #expect(viewModel.form == nil)
    }

    @Test func failureCanBeRetried() async throws {
        let viewModel = try await makeViewModel(.fixture())
        repository.setFails(.goal)
        await viewModel.load()
        #expect(viewModel.state == .failed)

        repository.setFails(.goal, false)
        await viewModel.load()
        #expect(viewModel.goal != nil)
    }

    @Test func savingReloadsTheGoal() async throws {
        var changes = 0
        let viewModel = try await makeViewModel(.fixture(target: 1000)) { changes += 1 }
        await viewModel.load()
        let form = try #require(viewModel.form)
        form.targetAmountText = "2000"
        repository.setGoals([.fixture(target: 2000)])

        #expect(await form.submit())

        #expect(changes == 1)
        #expect(viewModel.goal?.targetAmount == 2000)
        #expect(viewModel.form?.hasChanges == false)
        #expect(viewModel.showsUpdatedBanner)
    }

    // MARK: Cancel and delete (GOAL-24, GOAL-25)

    @Test func cancellingWithNothingSavedNeedsOnlyAConfirmation() async throws {
        var changed = false
        let viewModel = try await makeViewModel(.fixture(status: .notStarted, saved: 0, hasTransfers: false)) {
            changed = true
        }
        await viewModel.load()
        #expect(!viewModel.cancellationReturnsMoney)

        #expect(await viewModel.cancelWithoutTransfer())

        #expect(repository.cancelled == [101])
        #expect(transfers.made.isEmpty)
        #expect(changed)
    }

    @Test func cancellingWithMoneySavedGoesThroughTheSheet() async throws {
        let viewModel = try await makeViewModel(.fixture(saved: 400))
        await viewModel.load()

        #expect(viewModel.cancellationReturnsMoney)
        #expect(await !viewModel.cancelWithoutTransfer())
        #expect(repository.cancelled.isEmpty)
    }

    @Test func deletesOnlyWithoutTransfers() async throws {
        let viewModel = try await makeViewModel(.fixture(hasTransfers: true))
        await viewModel.load()
        #expect(await !viewModel.delete())

        repository.setGoals([.fixture(status: .notStarted, saved: 0, hasTransfers: false)])
        await viewModel.load()
        #expect(await viewModel.delete())
        #expect(repository.deleted == [101])
    }

    @Test func failedDeletionIsReported() async throws {
        let viewModel = try await makeViewModel(.fixture(saved: 0, hasTransfers: false))
        await viewModel.load()
        repository.setFails(.delete)

        #expect(await !viewModel.delete())
        #expect(viewModel.deletionFailure == "duplicate key value")
    }

    // MARK: Completing (GOAL-23)

    @Test func completingMovesEverythingSavedThenMarksTheGoal() async throws {
        var changes = 0
        let viewModel = try await makeViewModel(.fixture(target: 1000, saved: 1200)) { changes += 1 }
        await viewModel.load()
        let closing = try #require(viewModel.closing(.complete))

        #expect(closing.accounts == [usdCard])
        #expect(closing.account == usdCard)
        #expect(await closing.submit())

        let transfer = try #require(transfers.made.first)
        #expect(transfer.fromAccountID == 101)
        #expect(transfer.toAccountID == usdCard.id)
        #expect(transfer.fromAmount == 1200)
        #expect(repository.markedDone == [101])
        #expect(changes == 1)
    }

    @Test func failedMarkIsRetriedWithoutMovingTheMoneyAgain() async throws {
        let viewModel = try await makeViewModel(.fixture(target: 1000, saved: 1000))
        await viewModel.load()
        let closing = try #require(viewModel.closing(.complete))
        repository.setFails(.markDone)

        #expect(await !closing.submit())
        #expect(closing.hasMovedMoney)
        #expect(closing.failure == "duplicate key value")

        repository.setFails(.markDone, false)
        #expect(await closing.submit())

        #expect(transfers.made.count == 1)
        #expect(repository.markedDone == [101])
    }

    @Test func failedTransferMarksNothing() async throws {
        let viewModel = try await makeViewModel(.fixture(target: 1000, saved: 1000))
        await viewModel.load()
        let closing = try #require(viewModel.closing(.cancel))
        transfers.setMakeFails(true)

        #expect(await !closing.submit())

        #expect(!closing.hasMovedMoney)
        #expect(repository.cancelled.isEmpty)
    }

    @Test func closingNeedsAnAccountInTheGoalsCurrency() async throws {
        let viewModel = try await makeViewModel(.fixture(currencyCode: "CZK", saved: 50))
        await viewModel.load()
        let closing = try #require(viewModel.closing(.cancel))

        #expect(closing.needsAccount)
        #expect(await !closing.submit())
        #expect(closing.accountIssue == .required)
        #expect(transfers.made.isEmpty)
    }
}

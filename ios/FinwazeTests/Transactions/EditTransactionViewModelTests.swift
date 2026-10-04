import Foundation
import Testing
@testable import Finwaze

@MainActor
struct EditTransactionViewModelTests {
    private let cash = Account(id: 1, name: "Cash", currencyCode: "UAH")
    private let preferences = DevicePreferences(defaults: makeTestDefaults())
    private let repository = FakeTransactionsRepository()

    private func makeViewModel(
        preview: Transaction? = nil,
        onUpdated: @escaping () async -> Void = {},
        onDeleted: @escaping () async -> Void = {}
    ) async throws -> EditTransactionViewModel {
        let referenceData = try await makeReferenceData(
            FakeReferenceDataRepository(
                accounts: [cash],
                groups: [FakeReferenceDataRepository.food],
                categories: [FakeReferenceDataRepository.groceries]
            )
        )
        return EditTransactionViewModel(
            transactionID: 7,
            preview: preview,
            referenceData: referenceData,
            preferences: preferences,
            repository: repository,
            onUpdated: onUpdated,
            onDeleted: onDeleted
        )
    }

    private var transaction: Transaction {
        Transaction.fixture(id: 7, amount: -250, currencyCode: "UAH")
    }

    @Test func startsLoading() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.state.phase == .loading)
        #expect(viewModel.formViewModel == nil)
    }

    @Test func loadsTheTransaction() async throws {
        repository.setDetails(transaction)
        let viewModel = try await makeViewModel()

        await viewModel.load()

        #expect(viewModel.state.phase == .loaded)
        #expect(viewModel.formViewModel?.mode == .edit(transaction))
        #expect(repository.requestedIDs == [7])
    }

    @Test func notFoundWhenTheTransactionIsGone() async throws {
        let viewModel = try await makeViewModel()

        await viewModel.load()

        #expect(viewModel.state.phase == .notFound)
        #expect(viewModel.formViewModel == nil)
    }

    @Test func failedWhenLoadingErrors() async throws {
        repository.setFails(true)
        let viewModel = try await makeViewModel()

        await viewModel.load()

        #expect(viewModel.state.phase == .failed)
    }

    @Test func showsThePreviewBeforeLoading() async throws {
        let viewModel = try await makeViewModel(preview: transaction)

        #expect(viewModel.state.phase == .loaded)
        #expect(viewModel.formViewModel?.mode == .edit(transaction))
    }

    @Test func keepsThePreviewsFormWhenTheFreshCopyIsTheSame() async throws {
        repository.setDetails(transaction)
        let viewModel = try await makeViewModel(preview: transaction)
        let form = try #require(viewModel.formViewModel)

        await viewModel.load()

        #expect(viewModel.formViewModel === form)
        #expect(repository.requestedIDs == [7])
    }

    @Test func replacesThePreviewWithADifferentFreshCopy() async throws {
        let fresh = Transaction.fixture(id: 7, amount: -300, currencyCode: "UAH")
        repository.setDetails(fresh)
        let viewModel = try await makeViewModel(preview: transaction)

        await viewModel.load()

        #expect(viewModel.formViewModel?.mode == .edit(fresh))
    }

    @Test func keepsThePreviewWhenLoadingErrors() async throws {
        repository.setFails(true)
        let viewModel = try await makeViewModel(preview: transaction)

        await viewModel.load()

        #expect(viewModel.formViewModel?.mode == .edit(transaction))
    }

    @Test func notFoundReplacesThePreview() async throws {
        let viewModel = try await makeViewModel(preview: transaction)

        await viewModel.load()

        #expect(viewModel.state.phase == .notFound)
    }

    @Test func savingShowsTheBannerAndNotifies() async throws {
        repository.setDetails(transaction)
        var updates = 0
        let viewModel = try await makeViewModel(onUpdated: { updates += 1 })
        await viewModel.load()

        #expect(await viewModel.formViewModel?.submit() == true)

        #expect(viewModel.didSave)
        #expect(updates == 1)
    }

    @Test func applyNotFoundIfNeededSwitchesStateAfterAFailedSave() async throws {
        repository.setDetails(transaction)
        let viewModel = try await makeViewModel()
        await viewModel.load()
        let form = try #require(viewModel.formViewModel)
        // The transaction is deleted elsewhere while the screen stays open (`TX-42`).
        repository.removeDetails(id: transaction.id)

        #expect(await form.submit() == false)
        #expect(form.isNotFound)

        viewModel.applyNotFoundIfNeeded()

        #expect(viewModel.state.phase == .notFound)
    }

    @Test func deleteNotifiesOnSuccess() async throws {
        var deletions = 0
        let viewModel = try await makeViewModel(onDeleted: { deletions += 1 })

        #expect(await viewModel.delete())

        #expect(repository.deletedIDs == [7])
        #expect(deletions == 1)
        #expect(!viewModel.isDeleting)
    }

    @Test func deleteFailureSetsDeletionFailure() async throws {
        repository.setDeleteFails(true)
        var deletions = 0
        let viewModel = try await makeViewModel(onDeleted: { deletions += 1 })

        #expect(await viewModel.delete() == false)

        #expect(viewModel.deletionFailure == "duplicate key value")
        #expect(deletions == 0)
    }
}

/// The state without the form, which is not `Equatable`.
private enum Phase {
    case loading, loaded, notFound, failed
}

private extension DetailState {
    var phase: Phase {
        switch self {
        case .loading: .loading
        case .loaded: .loaded
        case .notFound: .notFound
        case .failed: .failed
        }
    }
}

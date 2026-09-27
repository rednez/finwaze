import Foundation
import Testing
@testable import Finwaze

@MainActor
struct TransferDetailsViewModelTests {
    private let repository = FakeTransfersRepository()

    private func makeViewModel(transactionID: Int64 = 11, onDeleted: @escaping () async -> Void = {}) -> TransferDetailsViewModel {
        TransferDetailsViewModel(transactionID: transactionID, repository: repository, onDeleted: onDeleted)
    }

    @Test func startsLoading() {
        #expect(makeViewModel().state == .loading)
    }

    @Test func loadsFromEitherRecord() async throws {
        let transfer = Transfer.fixture()
        repository.setDetails(transfer)

        for id in [transfer.sent.id, transfer.received.id] {
            let viewModel = makeViewModel(transactionID: id)
            await viewModel.load()
            #expect(viewModel.state == .loaded(transfer))
        }
        #expect(repository.requestedIDs == [11, 12])
    }

    @Test func showsTheRateOnlyWhenCurrenciesDiffer() async throws {
        repository.setDetails(.fixture(sent: 100, received: 4300))
        let exchange = makeViewModel()
        await exchange.load()

        #expect(exchange.exchangeRate == 43)

        repository.setDetails(.fixture(sent: 100, received: 100, receivedCurrency: "USD"))
        let sameCurrency = makeViewModel()
        await sameCurrency.load()

        #expect(sameCurrency.exchangeRate == nil)
    }

    @Test func notFoundWhenTheTransferIsGone() async {
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .notFound)
    }

    @Test func failedWhenLoadingErrors() async {
        repository.setLoadFails(true)
        let viewModel = makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .failed)
    }

    @Test func deletesTheWholeTransferAndNotifies() async throws {
        let transfer = Transfer.fixture()
        repository.setDetails(transfer)
        var deletions = 0
        let viewModel = makeViewModel(onDeleted: { deletions += 1 })
        await viewModel.load()

        #expect(await viewModel.delete())

        #expect(repository.deletedIDs == [transfer.id])
        #expect(deletions == 1)
        #expect(!viewModel.isDeleting)
    }

    @Test func deleteFailureKeepsTheScreen() async throws {
        repository.setDetails(.fixture())
        repository.setDeleteFails(true)
        var deletions = 0
        let viewModel = makeViewModel(onDeleted: { deletions += 1 })
        await viewModel.load()

        #expect(await viewModel.delete() == false)

        #expect(viewModel.deletionFailure == "duplicate key value")
        #expect(deletions == 0)
        #expect(viewModel.transfer != nil)
    }

    @Test func nothingToDeleteBeforeLoading() async {
        #expect(await makeViewModel().delete() == false)
        #expect(repository.deletedIDs.isEmpty)
    }
}

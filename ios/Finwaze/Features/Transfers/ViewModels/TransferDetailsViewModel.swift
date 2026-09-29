import Foundation
import Observation

/// "Transfer details" (`TRF-07`, `TRF-08`): loads both sides fresh from the server by the id of either record, and
/// deletes the whole transfer. A transfer cannot be edited: delete it and make it again.
@Observable
final class TransferDetailsViewModel {
    let transactionID: Int64
    private(set) var state: DetailState<Transfer> = .loading
    private(set) var isDeleting = false
    var deletionFailure: String?

    private let repository: any TransfersRepository
    private let onDeleted: () async -> Void

    init(transactionID: Int64, repository: any TransfersRepository, onDeleted: @escaping () async -> Void) {
        self.transactionID = transactionID
        self.repository = repository
        self.onDeleted = onDeleted
    }

    var transfer: Transfer? {
        state.value
    }

    /// The rate, only when the currencies differ (`TRF-07`): a same-currency transfer has a rate of exactly 1.
    var exchangeRate: Decimal? {
        guard let rate = transfer?.exchangeRate, rate != 1 else { return nil }
        return rate
    }

    /// Loads (or reloads) the transfer fresh from the server, not from the list it was opened from (`TX-06`).
    func load() async {
        state = .loading
        do {
            if let transfer = try await repository.transfer(transactionID: transactionID) {
                state = .loaded(transfer)
            } else {
                state = .notFound
            }
        } catch {
            state = .failed
        }
    }

    /// Deletes both records (`TRF-08`); `true` on success. Deleting an already-deleted transfer still succeeds.
    @discardableResult
    func delete() async -> Bool {
        guard let transfer, !isDeleting else { return false }
        isDeleting = true
        defer { isDeleting = false }
        do {
            try await repository.delete(transferID: transfer.id)
        } catch {
            deletionFailure = error.localizedDescription
            return false
        }
        await onDeleted()
        return true
    }
}

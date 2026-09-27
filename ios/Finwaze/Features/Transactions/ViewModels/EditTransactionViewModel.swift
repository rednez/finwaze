import Foundation
import Observation

/// The "Edit transaction" screen (`TX-06`, `TX-40…42`): loads fresh details by id, then owns saving, the success
/// banner and deletion. The form fields themselves are `TransactionFormViewModel`, in `.edit` mode.
@Observable
final class EditTransactionViewModel {
    enum State: Equatable {
        case loading
        case loaded
        /// The transaction no longer exists: deleted elsewhere, or never visible under RLS (`TX-42`).
        case notFound
        case failed
    }

    let transactionID: Int64
    private(set) var state: State = .loading
    private(set) var formViewModel: TransactionFormViewModel?
    /// A save just succeeded; the screen shows a banner that clears this itself (`TX-41`).
    var didSave = false
    private(set) var isDeleting = false
    var deletionFailure: String?

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    private let repository: any TransactionsRepository
    private let onUpdated: () async -> Void
    private let onDeleted: () async -> Void

    init(
        transactionID: Int64,
        referenceData: ReferenceDataStore,
        preferences: DevicePreferences,
        repository: any TransactionsRepository,
        onUpdated: @escaping () async -> Void,
        onDeleted: @escaping () async -> Void
    ) {
        self.transactionID = transactionID
        self.referenceData = referenceData
        self.preferences = preferences
        self.repository = repository
        self.onUpdated = onUpdated
        self.onDeleted = onDeleted
    }

    /// Loads (or reloads) the transaction fresh from the server, not from the list it was opened from (`TX-06`).
    func load() async {
        state = .loading
        formViewModel = nil
        do {
            guard let transaction = try await repository.transaction(id: transactionID) else {
                state = .notFound
                return
            }
            formViewModel = TransactionFormViewModel(
                mode: .edit(transaction),
                referenceData: referenceData,
                preferences: preferences,
                repository: repository,
                onSaved: { [weak self] in await self?.saved() }
            )
            state = .loaded
        } catch {
            state = .failed
        }
    }

    /// After `formViewModel.submit()` answers `false`, checks whether it was because the transaction was deleted
    /// elsewhere while this screen was open, and switches to the "not found" state if so (`TX-42`).
    func applyNotFoundIfNeeded() {
        if formViewModel?.isNotFound == true {
            state = .notFound
        }
    }

    @discardableResult
    func delete() async -> Bool {
        isDeleting = true
        defer { isDeleting = false }
        do {
            // Deleting an already-deleted transaction still succeeds (`TX-41`).
            try await repository.delete(id: transactionID)
        } catch {
            deletionFailure = error.localizedDescription
            return false
        }
        await onDeleted()
        return true
    }

    private func saved() async {
        didSave = true
        await onUpdated()
    }
}

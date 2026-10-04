import Foundation
import Observation

/// The "Edit transaction" screen (`TX-06`, `TX-40…42`): shows the list's copy straight away and loads fresh details
/// by id, then owns saving, the success banner and deletion. The form fields themselves are `TransactionFormViewModel`, in `.edit` mode.
@Observable
final class EditTransactionViewModel {
    let transactionID: Int64
    /// Loaded with the form, filled from the latest copy.
    private(set) var state: DetailState<TransactionFormViewModel> = .loading
    /// The transaction the form was filled from.
    private var shown: Transaction?
    /// A save just succeeded; the screen shows a banner that clears this itself (`TX-41`).
    var didSave = false
    private(set) var isDeleting = false
    var deletionFailure: String?

    private let referenceData: ReferenceDataStore
    private let preferences: DevicePreferences
    private let repository: any TransactionsRepository
    private let onUpdated: () async -> Void
    private let onDeleted: () async -> Void

    /// With a `preview` from the list, the form is filled from it at once, so the push shows the form rather than a
    /// spinner; `load()` then swaps in the fresh copy if it differs.
    init(
        transactionID: Int64,
        preview: Transaction? = nil,
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
        if let preview {
            show(preview)
        }
    }

    /// Loads (or reloads) the transaction fresh from the server, not from the list it was opened from (`TX-06`). While
    /// the list's copy is shown, it stays on screen and is replaced only by a different fresh copy; a failed request
    /// leaves it be, as saving goes to the server anyway.
    func load() async {
        let isShowing = state.value != nil
        if !isShowing {
            state = .loading
        }
        do {
            guard let transaction = try await repository.transaction(id: transactionID) else {
                state = .notFound
                return
            }
            if transaction != shown || !isShowing {
                show(transaction)
            }
        } catch {
            if !isShowing {
                state = .failed
            }
        }
    }

    private func show(_ transaction: Transaction) {
        shown = transaction
        state = .loaded(TransactionFormViewModel(
            mode: .edit(transaction),
            referenceData: referenceData,
            preferences: preferences,
            repository: repository,
            onSaved: { [weak self] in await self?.saved() }
        ))
    }

    var formViewModel: TransactionFormViewModel? {
        state.value
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

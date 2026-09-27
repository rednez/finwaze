import Foundation
import Observation

/// The Wallet's account cards (`ACC-02`) with loading, empty and error states (`GEN-23…25`).
@Observable
final class WalletViewModel {
    enum State: Equatable {
        case loading
        case loaded([WalletAccount])
        case failed
    }

    private(set) var state: State = .loading

    private let repository: any WalletRepository

    init(repository: any WalletRepository) {
        self.repository = repository
    }

    /// Loads the accounts. A reload keeps the cards on screen until the new ones arrive (`GEN-26`).
    func load() async {
        if case .failed = state {
            state = .loading
        }
        do {
            state = .loaded(try await repository.accounts())
        } catch {
            guard !Task.isCancelled else { return }
            state = .failed
        }
    }
}

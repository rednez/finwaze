import Foundation
import Observation

/// The new-account form shared by onboarding (`ONB-02`) and the Wallet's "New account" (`ACC-07`).
@Observable
final class AccountFormViewModel {
    enum NameIssue: Equatable {
        /// Empty, shorter than 3 or longer than 30 characters — one message covers all, like on the web.
        case length
    }

    enum CurrencyIssue: Equatable {
        case required
    }

    static let nameLength = 3...30

    var name = ""
    var currency: Currency?
    /// The server's explanation of a failed create; the entered data stays in the form (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let repository: any AccountsRepository
    /// Runs after the account is created, while the button still shows its spinner.
    private let onCreated: (Account) async -> Void

    init(repository: any AccountsRepository, onCreated: @escaping (Account) async -> Void) {
        self.repository = repository
        self.onCreated = onCreated
    }

    var nameIssue: NameIssue? {
        guard showsValidation else { return nil }
        return Self.nameLength.contains(trimmedName.count) ? nil : .length
    }

    var currencyIssue: CurrencyIssue? {
        showsValidation && currency == nil ? .required : nil
    }

    /// Creates the account; `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard !isSubmitting, nameIssue == nil, currencyIssue == nil, let currency else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            let account = try await repository.createAccount(name: trimmedName, currencyID: currency.id)
            await onCreated(account)
            return true
        } catch {
            failure = error.localizedDescription
            return false
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

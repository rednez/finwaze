import Foundation
import Observation

/// "New group", "New category" and their editing (`TX-12`, `CAT-04…08`): a name, required and at most 25 characters,
/// the limit the database enforces for both, an optional colour from the palette (`CAT-10`) and, for a new group
/// created outside the category picker, its type (`CAT-04`).
@Observable
final class NamePromptViewModel {
    enum NameIssue: Equatable {
        case required
        case tooLong
    }

    /// What the form submits.
    struct Input: Equatable, Sendable {
        let name: String
        let color: String?
        /// The chosen type of a new group; `nil` when the form does not ask for it.
        let type: TransactionType?
    }

    static let nameLimit = 25

    var name: String
    /// A colour from `ColorPalette`, or `nil` for none — the default.
    var color: String?
    /// Expense or income for a new group; `nil` hides the choice — the type is fixed by the caller or, for an
    /// existing group, can no longer change (`CAT-04`).
    var type: TransactionType?
    /// The server's explanation of a failed create; the entered name stays (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let save: (Input) async throws -> Void

    /// `name` and `color` pre-fill the form when editing an existing group or category.
    init(
        name: String = "",
        color: String? = nil,
        type: TransactionType? = nil,
        save: @escaping (Input) async throws -> Void
    ) {
        self.name = name
        self.color = color
        self.type = type
        self.save = save
    }

    var nameIssue: NameIssue? {
        guard showsValidation else { return nil }
        if trimmedName.isEmpty { return .required }
        return trimmedName.count > Self.nameLimit ? .tooLong : nil
    }

    /// Creates or saves the item; `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard !isSubmitting, nameIssue == nil else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await save(Input(name: trimmedName, color: color, type: type))
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

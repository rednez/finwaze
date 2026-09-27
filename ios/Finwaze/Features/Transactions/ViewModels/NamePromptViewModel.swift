import Foundation
import Observation

/// "New group" and "New category" from the category picker (`TX-12`): a name, required and at most 25 characters,
/// the limit the database enforces for both, and an optional colour from the palette (`CAT-10`).
@Observable
final class NamePromptViewModel {
    enum NameIssue: Equatable {
        case required
        case tooLong
    }

    static let nameLimit = 25

    var name = ""
    /// A colour from `ColorPalette`, or `nil` for none — the default.
    var color: String?
    /// The server's explanation of a failed create; the entered name stays (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let create: (_ name: String, _ color: String?) async throws -> Void

    init(create: @escaping (_ name: String, _ color: String?) async throws -> Void) {
        self.create = create
    }

    var nameIssue: NameIssue? {
        guard showsValidation else { return nil }
        if trimmedName.isEmpty { return .required }
        return trimmedName.count > Self.nameLimit ? .tooLong : nil
    }

    /// Creates the item; `true` on success. Ignored while a request is running (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard !isSubmitting, nameIssue == nil else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            try await create(trimmedName, color)
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

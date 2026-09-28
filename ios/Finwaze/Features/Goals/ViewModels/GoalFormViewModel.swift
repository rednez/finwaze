import Foundation
import Observation

/// The goal form (`GOAL-20…22`): "New goal", or a goal's own fields on its screen. The currency is chosen only when
/// creating; a done or cancelled goal is read-only.
@Observable
final class GoalFormViewModel {
    enum Mode: Equatable {
        case create
        case edit(SavingsGoal)
    }

    enum NameIssue: Equatable {
        /// Empty, shorter than 3 or longer than 30 characters — one message covers all, like on the web.
        case length
    }

    enum AmountIssue: Equatable {
        case input(PositiveAmountInput.Issue)
        /// The target is at least 1 (`GOAL-20`).
        case belowMinimum
    }

    enum DateIssue: Equatable {
        case required
        /// Not earlier than today (`GOAL-20`).
        case inPast
    }

    enum CurrencyIssue: Equatable {
        case required
    }

    static let nameLength = 3...30
    static let minimumTarget: Decimal = 1

    let mode: Mode
    var name = ""
    var targetAmountText = ""
    /// A calendar day; `nil` until picked for a new goal.
    var targetDate: Date?
    var currency: Currency?
    /// The server's explanation of a failed save; the entered data stays in the form (`GEN-19`).
    var failure: String?
    private(set) var isSubmitting = false
    /// Field errors stay hidden until the first submit (`GEN-21`).
    private(set) var showsValidation = false

    private let referenceData: ReferenceDataStore
    private let repository: any GoalsRepository
    private let clock: () -> Date
    private let calendar: Calendar
    /// Runs after the goal is saved, while the button still shows its spinner.
    private let onSaved: () async -> Void

    init(
        mode: Mode,
        referenceData: ReferenceDataStore,
        repository: any GoalsRepository,
        defaultCurrencyCode: String? = nil,
        clock: @escaping () -> Date = { .now },
        calendar: Calendar = .current,
        locale: Locale = .current,
        onSaved: @escaping () async -> Void
    ) {
        self.mode = mode
        self.referenceData = referenceData
        self.repository = repository
        self.clock = clock
        self.calendar = calendar
        self.onSaved = onSaved
        switch mode {
        case .create:
            currency = referenceData.currencies.first { $0.code == defaultCurrencyCode }
        case .edit(let goal):
            name = goal.name
            targetAmountText = goal.targetAmount.inputText(locale: locale)
            targetDate = goal.targetDate
            currency = referenceData.currencies.first { $0.code == goal.currencyCode }
        }
    }

    var isEditing: Bool {
        mode != .create
    }

    /// The full directory, only when creating: the currency never changes afterwards (`GOAL-20`).
    var currencies: [Currency] {
        referenceData.currencies
    }

    /// The goal's currency code, shown even when it is not in the directory.
    var currencyCode: String? {
        if case .edit(let goal) = mode { return goal.currencyCode }
        return currency?.code
    }

    /// A done or cancelled goal is only for viewing (`GOAL-04`, `GOAL-22`).
    var isReadOnly: Bool {
        if case .edit(let goal) = mode { return !goal.isActive }
        return false
    }

    /// Today, or the saved date if it is earlier, so an overdue goal can be edited without moving it (`GOAL-20`).
    var earliestDate: Date {
        let today = calendar.startOfDay(for: clock())
        if case .edit(let goal) = mode { return min(today, goal.targetDate) }
        return today
    }

    /// Whether anything differs from the saved goal; always `true` for a new one.
    var hasChanges: Bool {
        guard case .edit(let goal) = mode else { return true }
        let amount = try? PositiveAmountInput.parse(targetAmountText).get()
        return trimmedName != goal.name
            || amount != goal.targetAmount
            || targetDate.map { !calendar.isDate($0, inSameDayAs: goal.targetDate) } ?? true
    }

    // MARK: Validation (GEN-21)

    var nameIssue: NameIssue? {
        guard showsValidation else { return nil }
        return Self.nameLength.contains(trimmedName.count) ? nil : .length
    }

    var amountIssue: AmountIssue? {
        guard showsValidation else { return nil }
        switch PositiveAmountInput.parse(targetAmountText) {
        case .failure(let issue): return .input(issue)
        case .success(let amount): return amount < Self.minimumTarget ? .belowMinimum : nil
        }
    }

    var dateIssue: DateIssue? {
        guard showsValidation else { return nil }
        guard let targetDate else { return .required }
        return calendar.startOfDay(for: targetDate) < earliestDate ? .inPast : nil
    }

    var currencyIssue: CurrencyIssue? {
        showsValidation && !isEditing && currency == nil ? .required : nil
    }

    // MARK: Submit

    /// Creates or updates the goal; `true` on success. Ignored while a request is running or when read-only
    /// (`GEN-20`).
    @discardableResult
    func submit() async -> Bool {
        showsValidation = true
        guard
            !isSubmitting, !isReadOnly,
            nameIssue == nil, amountIssue == nil, dateIssue == nil, currencyIssue == nil,
            let amount = try? PositiveAmountInput.parse(targetAmountText).get(),
            let targetDate
        else { return false }

        let day = calendar.startOfDay(for: targetDate)
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            switch mode {
            case .create:
                guard let currency else { return false }
                _ = try await repository.create(
                    NewSavingsGoal(name: trimmedName, currencyID: currency.id, targetAmount: amount, targetDate: day)
                )
            case .edit(let goal):
                try await repository.update(
                    id: goal.id,
                    SavingsGoalUpdate(name: trimmedName, targetAmount: amount, targetDate: day)
                )
            }
        } catch {
            failure = error.localizedDescription
            return false
        }
        await onSaved()
        return true
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

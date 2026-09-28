import Foundation
import Observation

/// The plan editor (`BUD-20…26`) for one month and currency: loads the saved plan, offers to generate one or start
/// by hand when there is none, and saves the whole plan at once.
@Observable
final class BudgetPlanViewModel {
    enum State: Equatable {
        case loading
        /// The plan could not be loaded (`GEN-25`).
        case failed
        /// No plan yet: "Generate" or "Create manually" (`BUD-21`).
        case empty
        case editing
    }

    /// What `save()` did, for the screen to follow up.
    enum SaveOutcome: Equatable {
        case saved
        /// Some amounts are invalid; the screen focuses the first (`GEN-21`).
        case invalid(firstCategoryID: Int64)
        /// The plan would be deleted; the screen asks first (`GEN-22`).
        case needsConfirmation
        /// Failed, or ignored while another save runs (`GEN-19`, `GEN-20`).
        case notSaved
    }

    let month: YearMonth
    let currencyCode: String
    private(set) var state: State = .loading
    private(set) var draft = BudgetPlanDraft()
    /// Collapsed groups, by id; new groups start expanded.
    var collapsedGroupIDs: Set<Int64> = []
    private(set) var isGenerating = false
    /// "Generate" found nothing to generate from (`BUD-21`).
    var showsNothingToGenerate = false
    /// The server's explanation of a failed generation.
    var generateFailure: String?
    private(set) var isSaving = false
    /// The server's explanation of a failed save; the draft stays as it is (`GEN-19`).
    var saveFailure: String?
    /// A save just succeeded; the screen shows a banner that clears this itself.
    var didSave = false
    /// Amount errors stay hidden until the first save (`GEN-21`).
    private(set) var showsValidation = false

    private let repository: any BudgetRepository
    private let referenceData: ReferenceDataStore
    private let onSaved: () -> Void

    init(
        month: YearMonth,
        currencyCode: String,
        repository: any BudgetRepository,
        referenceData: ReferenceDataStore,
        onSaved: @escaping () -> Void
    ) {
        self.month = month
        self.currencyCode = currencyCode
        self.repository = repository
        self.referenceData = referenceData
        self.onSaved = onSaved
    }

    // MARK: Loading (BUD-20, BUD-21)

    func load() async {
        state = .loading
        do {
            let lines = try await repository.plan(month: month, currencyCode: currencyCode)
            draft = .saved(lines)
            collapsedGroupIDs = []
            state = lines.isEmpty ? .empty : .editing
        } catch {
            state = .failed
        }
    }

    /// Fills the draft with a proposed plan, not saved yet (`BUD-21`). Ignored while a request runs (`GEN-20`).
    func generate() async {
        guard !isGenerating else { return }
        isGenerating = true
        defer { isGenerating = false }
        do {
            let lines = try await repository.generatedPlan(month: month, currencyCode: currencyCode)
            guard !lines.isEmpty else {
                showsNothingToGenerate = true
                return
            }
            draft = BudgetPlanDraft(lines: lines, saved: draft.saved)
            collapsedGroupIDs = []
            state = .editing
        } catch {
            generateFailure = error.localizedDescription
        }
    }

    /// An empty draft; the screen then offers "Add group" (`BUD-21`).
    func startManually() {
        draft = BudgetPlanDraft(saved: draft.saved)
        collapsedGroupIDs = []
        state = .editing
    }

    // MARK: Names

    /// The group's current name — it may have been renamed since the plan was loaded — or the server's.
    func name(ofGroup section: BudgetPlanDraft.Section) -> String {
        referenceData.groups.first { $0.id == section.id }?.name ?? section.fallbackName
    }

    func name(ofCategory line: BudgetPlanDraft.Line) -> String {
        referenceData.categories.first { $0.id == line.id }?.name ?? line.fallbackName
    }

    // MARK: Editing (BUD-23, BUD-24)

    /// Expense groups not in the plan, by name (`GEN-05`: the reference data has no system groups).
    var availableGroups: [CategoryGroup] {
        draft.availableGroups(referenceData.groups).sorted { Self.isOrdered($0.name, $1.name) }
    }

    func availableCategories(inGroup groupID: Int64) -> [Category] {
        draft.availableCategories(inGroup: groupID, referenceData.categories)
            .sorted { Self.isOrdered($0.name, $1.name) }
    }

    func addGroup(_ group: CategoryGroup) {
        draft.addGroup(id: group.id, name: group.name)
        collapsedGroupIDs.remove(group.id)
    }

    func removeGroup(id: Int64) {
        draft.removeGroup(id: id)
        collapsedGroupIDs.remove(id)
    }

    /// Adds the category right away with an empty amount, then loads its reference figures; if that fails the row
    /// keeps "—" (`BUD-24`).
    func addCategory(_ category: Category) async {
        let groupName = referenceData.groups.first { $0.id == category.groupID }?.name ?? ""
        draft.addCategory(category, groupName: groupName)
        collapsedGroupIDs.remove(category.groupID)
        guard let stats = try? await repository.categoryStats(
            month: month,
            currencyCode: currencyCode,
            categoryID: category.id
        ) else { return }
        draft.setStats(stats, for: category.id)
    }

    func removeCategory(id: Int64) {
        draft.removeCategory(id: id)
    }

    func setAmountText(_ text: String, for categoryID: Int64) {
        draft.setAmountText(text, for: categoryID)
    }

    /// Shown only after the first save (`GEN-21`).
    func issue(for categoryID: Int64) -> PositiveAmountInput.Issue? {
        showsValidation ? draft.issue(for: categoryID) : nil
    }

    // MARK: Collapsing

    func toggleGroup(_ id: Int64) {
        if collapsedGroupIDs.contains(id) {
            collapsedGroupIDs.remove(id)
        } else {
            collapsedGroupIDs.insert(id)
        }
    }

    func collapseAll() {
        collapsedGroupIDs = Set(draft.sections.map(\.id))
    }

    func expandAll() {
        collapsedGroupIDs = []
    }

    // MARK: Saving (BUD-25, BUD-26)

    /// "Save" is enabled only with changes (`BUD-26`).
    var canSave: Bool {
        state == .editing && draft.isDirty
    }

    /// Closing asks first (`NAV-05`).
    var hasUnsavedChanges: Bool {
        state == .editing && draft.isDirty
    }

    /// Saves the whole plan. Deleting a saved plan completely needs `confirmed` (`GEN-22`).
    @discardableResult
    func save(confirmed: Bool = false) async -> SaveOutcome {
        guard !isSaving, state == .editing else { return .notSaved }
        showsValidation = true
        if let id = draft.firstInvalidCategoryID {
            // Also shows the errors of collapsed groups.
            collapsedGroupIDs = []
            return .invalid(firstCategoryID: id)
        }
        guard let amounts = draft.payload else { return .notSaved }
        if draft.deletesSavedPlan, !confirmed {
            return .needsConfirmation
        }

        isSaving = true
        defer { isSaving = false }
        do {
            try await repository.savePlan(month: month, currencyCode: currencyCode, amounts: amounts)
        } catch {
            saveFailure = error.localizedDescription
            return .notSaved
        }
        draft.markSaved(amounts)
        showsValidation = false
        didSave = true
        onSaved()
        return .saved
    }

    private static func isOrdered(_ lhs: String, _ rhs: String) -> Bool {
        lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
}

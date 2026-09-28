import SwiftUI

/// The plan editor (`BUD-20…26`) for the Budget's month and currency: the saved plan, or "Generate" / "Create
/// manually" when there is none. Saving keeps the editor open (like the web); closing with changes asks first
/// (`NAV-05`).
struct BudgetPlanView: View {
    @State private var viewModel: BudgetPlanViewModel
    @State private var isConfirmingDiscard = false
    @State private var isConfirmingDelete = false
    @State private var isAddingGroup = false
    @FocusState private var focusedCategoryID: Int64?
    @Environment(\.dismiss) private var dismiss

    init(app: AppViewModel, month: YearMonth, currencyCode: String) {
        _viewModel = State(initialValue: BudgetPlanViewModel(
            month: month,
            currencyCode: currencyCode,
            repository: app.repositories.budget,
            referenceData: app.referenceData,
            onSaved: { app.budgetSaved() }
        ))
    }

    var body: some View {
        NavigationStack {
            content
                .background(Color(.systemGroupedBackground))
                .navigationTitle(Text("budget.plan.title \(viewModel.month.inlineTitle)"))
                .navigationSubtitle(Text(verbatim: viewModel.currencyCode))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
                .overlay(alignment: .top) {
                    if viewModel.didSave {
                        SuccessBanner(message: "budget.plan.saved") { viewModel.didSave = false }
                    }
                }
                .failureAlert($viewModel.saveFailure, title: "budget.plan.saveFailed")
                .failureAlert($viewModel.generateFailure, title: "budget.plan.generateFailed")
                .confirmationDialog(
                    "budget.plan.discard.title",
                    isPresented: $isConfirmingDiscard,
                    titleVisibility: .visible
                ) {
                    Button("budget.plan.discard", role: .destructive) { dismiss() }
                    Button("budget.plan.keepEditing", role: .cancel) {}
                }
                // Saving an emptied plan deletes the month's plan (`GEN-22`).
                .confirmationDialog(
                    Text("budget.plan.deleteAll.title \(viewModel.month.inlineTitle)"),
                    isPresented: $isConfirmingDelete,
                    titleVisibility: .visible
                ) {
                    Button("budget.plan.deleteAll", role: .destructive) {
                        Task { await viewModel.save(confirmed: true) }
                    }
                    Button("common.cancel", role: .cancel) {}
                }
        }
        .task { await viewModel.load() }
        .interactiveDismissDisabled(viewModel.hasUnsavedChanges || viewModel.isSaving)
        .presentationDetents([.large])
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed:
            ContentUnavailableView {
                Label("error.generic.title", systemImage: "exclamationmark.triangle")
            } description: {
                Text("error.generic.message")
            } actions: {
                Button("common.retry", systemImage: "arrow.clockwise") {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.glassProminent)
            }
        case .empty:
            BudgetPlanEmptyView(viewModel: viewModel) {
                viewModel.startManually()
                isAddingGroup = true
            }
        case .editing:
            BudgetPlanEditor(viewModel: viewModel, isAddingGroup: $isAddingGroup, focus: $focusedCategoryID)
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("common.close", role: .close, action: close)
        }
        if viewModel.state == .editing {
            if !viewModel.draft.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Menu("budget.plan.more", systemImage: "ellipsis") {
                        Button("budget.plan.collapseAll", systemImage: "rectangle.compress.vertical") {
                            withAnimation { viewModel.collapseAll() }
                        }
                        Button("budget.plan.expandAll", systemImage: "rectangle.expand.vertical") {
                            withAnimation { viewModel.expandAll() }
                        }
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isSaving {
                    ProgressView()
                        .accessibilityLabel(Text("common.loading"))
                } else {
                    Button("budget.plan.save", role: .confirm, action: save)
                        .disabled(!viewModel.canSave)
                }
            }
        }
    }

    private func close() {
        if viewModel.hasUnsavedChanges {
            isConfirmingDiscard = true
        } else {
            dismiss()
        }
    }

    private func save() {
        Task {
            switch await viewModel.save() {
            case .invalid(let categoryID):
                focusedCategoryID = categoryID
            case .needsConfirmation:
                isConfirmingDelete = true
            case .saved, .notSaved:
                break
            }
        }
    }
}

/// No plan for the month yet (`BUD-21`).
private struct BudgetPlanEmptyView: View {
    @Bindable var viewModel: BudgetPlanViewModel
    let onCreateManually: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label {
                Text("budget.plan.noBudget \(viewModel.month.inlineTitle) \(viewModel.currencyCode)")
            } icon: {
                Image(systemName: "chart.pie")
            }
        } description: {
            Text("budget.plan.canGenerate")
        } actions: {
            Button {
                Task { await viewModel.generate() }
            } label: {
                if viewModel.isGenerating {
                    ProgressView()
                        .accessibilityLabel(Text("common.loading"))
                } else {
                    Label("budget.plan.generate", systemImage: "wand.and.stars")
                }
            }
            .buttonStyle(.glassProminent)

            Button("budget.plan.createManually", systemImage: "hand.point.up.left", action: onCreateManually)
                .buttonStyle(.glass)
                .disabled(viewModel.isGenerating)
        }
        .alert("budget.plan.nothingToGenerate", isPresented: $viewModel.showsNothingToGenerate) {
            Button("common.ok", role: .cancel) {}
        }
    }
}

/// The plan as a list: a section per group with its categories and total, then the whole plan's total (`BUD-22`).
private struct BudgetPlanEditor: View {
    /// Which group "Add category" is picking for.
    private struct CategoryPick: Identifiable {
        let id: Int64
    }

    let viewModel: BudgetPlanViewModel
    @Binding var isAddingGroup: Bool
    let focus: FocusState<Int64?>.Binding
    @State private var categoryPick: CategoryPick?
    /// A group just added, which offers "Add category" as soon as its sheet closes (`BUD-23`).
    @State private var addedGroupID: Int64?
    /// A category just added, which takes the focus as soon as its sheet closes (`BUD-24`).
    @State private var addedCategoryID: Int64?
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        List {
            if sizeClass == .regular, !viewModel.draft.isEmpty {
                Section {
                } header: {
                    BudgetPlanColumnTitles()
                        .textCase(nil)
                }
            }
            ForEach(viewModel.draft.sections) { section in
                groupSection(section)
            }
            Section {
                Button("budget.plan.addGroup", systemImage: "plus") { isAddingGroup = true }
                    .disabled(viewModel.availableGroups.isEmpty)
            }
            if !viewModel.draft.lines.isEmpty {
                Section {
                    BudgetPlanTotalsRow(
                        title: "budget.plan.total",
                        totals: viewModel.draft.totals,
                        currencyCode: viewModel.currencyCode
                    )
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .sheet(isPresented: $isAddingGroup, onDismiss: offerCategoryForAddedGroup) {
            BudgetPlanPickerSheet(
                title: "budget.plan.selectGroup",
                options: viewModel.availableGroups.map { .init(id: $0.id, name: $0.name) }
            ) { id in
                guard let group = viewModel.availableGroups.first(where: { $0.id == id }) else { return }
                viewModel.addGroup(group)
                addedGroupID = id
            }
        }
        .sheet(item: $categoryPick, onDismiss: focusAddedCategory) { pick in
            BudgetPlanPickerSheet(
                title: "budget.plan.selectCategory",
                options: viewModel.availableCategories(inGroup: pick.id).map { .init(id: $0.id, name: $0.name) }
            ) { id in
                guard let category = viewModel.availableCategories(inGroup: pick.id).first(where: { $0.id == id })
                else { return }
                addedCategoryID = id
                Task { await viewModel.addCategory(category) }
            }
        }
    }

    private func groupSection(_ section: BudgetPlanDraft.Section) -> some View {
        let isExpanded = !viewModel.collapsedGroupIDs.contains(section.id)
        return Section {
            if isExpanded {
                if section.lines.isEmpty {
                    Text("budget.plan.addCategoryHint")
                        .foregroundStyle(.secondary)
                }
                ForEach(section.lines) { line in
                    categoryRow(line)
                }
                if !section.lines.isEmpty {
                    BudgetPlanTotalsRow(
                        title: "budget.plan.groupTotal",
                        totals: viewModel.draft.totals(ofGroup: section.id),
                        currencyCode: viewModel.currencyCode
                    )
                }
                Button("budget.plan.addCategory", systemImage: "plus") {
                    categoryPick = CategoryPick(id: section.id)
                }
                .disabled(viewModel.availableCategories(inGroup: section.id).isEmpty)
            }
        } header: {
            BudgetPlanGroupHeader(
                name: viewModel.name(ofGroup: section),
                planned: viewModel.draft.totals(ofGroup: section.id).planned
                    .formattedAmount(currencyCode: viewModel.currencyCode),
                isExpanded: isExpanded,
                onToggle: { withAnimation { viewModel.toggleGroup(section.id) } },
                onDelete: { withAnimation { viewModel.removeGroup(id: section.id) } }
            )
        }
    }

    private func categoryRow(_ line: BudgetPlanDraft.Line) -> some View {
        BudgetPlanCategoryRow(
            name: viewModel.name(ofCategory: line),
            amountText: Binding(
                get: { viewModel.draft.line(line.id)?.amountText ?? "" },
                set: { viewModel.setAmountText($0, for: line.id) }
            ),
            stats: line.stats,
            currencyCode: viewModel.currencyCode,
            issue: viewModel.issue(for: line.id),
            focus: focus,
            categoryID: line.id
        )
        // No confirmation: it only changes the draft, which "Close" discards (`GEN-22`).
        .swipeActions {
            Button("budget.plan.deleteCategory", systemImage: "trash", role: .destructive) {
                withAnimation { viewModel.removeCategory(id: line.id) }
            }
        }
        .contextMenu {
            Button("budget.plan.deleteCategory", systemImage: "trash", role: .destructive) {
                withAnimation { viewModel.removeCategory(id: line.id) }
            }
        }
    }

    private func offerCategoryForAddedGroup() {
        guard let id = addedGroupID else { return }
        addedGroupID = nil
        if !viewModel.availableCategories(inGroup: id).isEmpty {
            categoryPick = CategoryPick(id: id)
        }
    }

    private func focusAddedCategory() {
        guard let id = addedCategoryID else { return }
        addedCategoryID = nil
        focus.wrappedValue = id
    }
}

/// A group's section header: its name and planned total, collapsing, and "Delete group" (`BUD-22`, `BUD-23`).
private struct BudgetPlanGroupHeader: View {
    let name: String
    let planned: String
    let isExpanded: Bool
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(action: onToggle) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                    Text(verbatim: name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 8)
                    Text(verbatim: planned)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(verbatim: name))
            .accessibilityValue(Text(verbatim: planned))
            .accessibilityHint(Text(isExpanded ? "budget.plan.collapse" : "budget.plan.expand"))
            .accessibilityAddTraits(.isHeader)

            Menu {
                Button("budget.plan.deleteGroup", systemImage: "trash", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.large)
                    .accessibilityLabel(Text("budget.plan.groupActions \(name)"))
            }
        }
        .textCase(nil)
    }
}

extension YearMonth {
    /// "September 2026" as it reads inside a sentence — "вересень 2026 р." — without the capital letter `title` adds.
    var inlineTitle: String {
        start(in: .current)?.formattedMonth() ?? ""
    }
}

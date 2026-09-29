import SwiftUI

/// "Groups & categories" (`CAT-01…12`): a section per group with its categories and their transaction counts, a type
/// filter, and editing through context menus and swipes — the platform's way instead of the web's in-place editing.
struct GroupsView: View {
    private enum Prompt: Identifiable {
        case newGroup
        case newCategory(groupID: Int64)
        case editGroup(GroupWithCategories)
        case editCategory(GroupWithCategories.Item)

        var id: String {
            switch self {
            case .newGroup: "new-group"
            case .newCategory(let groupID): "new-category-\(groupID)"
            case .editGroup(let group): "group-\(group.id)"
            case .editCategory(let category): "category-\(category.id)"
            }
        }
    }

    private enum Deletion: Identifiable {
        case group(GroupWithCategories)
        case category(GroupWithCategories.Item)

        var id: String {
            switch self {
            case .group(let group): "group-\(group.id)"
            case .category(let category): "category-\(category.id)"
            }
        }

        var name: String {
            switch self {
            case .group(let group): group.name
            case .category(let category): category.name
            }
        }
    }

    @Environment(AppViewModel.self) private var app
    @State private var viewModel: GroupsViewModel
    /// "Add group" is open; set by the section's "+" or the empty state (`CAT-04`).
    @Binding var isAddingGroup: Bool
    @State private var prompt: Prompt?
    @State private var pendingDeletion: Deletion?

    init(app: AppViewModel, isAddingGroup: Binding<Bool>) {
        _isAddingGroup = isAddingGroup
        _viewModel = State(
            initialValue: GroupsViewModel(
                repository: app.repositories.groups,
                createGroup: { _ = try await app.createGroup(name: $0, type: $1, color: $2) },
                createCategory: { _ = try await app.createCategory(name: $0, groupID: $1, color: $2) },
                onChanged: { await app.referenceDataChanged() }
            )
        )
    }

    var body: some View {
        content
            // Follows every change, including groups and categories created from the category picker (`GEN-26`).
            .task(id: app.dataVersion) { await viewModel.load(dataVersion: app.dataVersion) }
            .refreshable { await viewModel.refresh() }
            .onChange(of: isAddingGroup, initial: true) { _, isAdding in
                guard isAdding else { return }
                prompt = .newGroup
                isAddingGroup = false
            }
            .sheet(item: $prompt, content: promptView)
            // A destructive confirmation before deleting (`GEN-22`, `Q-01`).
            .confirmationDialog(
                "groups.deleteConfirmTitle \(pendingDeletion?.name ?? "")",
                isPresented: Binding(get: { pendingDeletion != nil }, set: { if !$0 { pendingDeletion = nil } }),
                titleVisibility: .visible,
                presenting: pendingDeletion
            ) { deletion in
                Button("groups.delete", role: .destructive) {
                    Task { await delete(deletion) }
                }
                Button("common.cancel", role: .cancel) {}
            }
            .alert(
                viewModel.failure.map { Text($0.title) } ?? Text(verbatim: ""),
                isPresented: Binding(get: { viewModel.failure != nil }, set: { if !$0 { viewModel.failure = nil } }),
                presenting: viewModel.failure
            ) { _ in
                Button("common.ok", role: .cancel) {}
            } message: { failure in
                Text(verbatim: failure.message)
            }
            .overlay(alignment: .top) {
                if let banner = viewModel.banner {
                    SuccessBanner(message: banner) { viewModel.banner = nil }
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
        case .failed:
            ScreenErrorView(onRetry: { Task { await viewModel.refresh() } })
        case .loaded where viewModel.hasNoGroups:
            // `CAT-12`.
            ContentUnavailableView {
                Label("groups.empty.title", systemImage: "folder")
            } description: {
                Text("groups.empty.message")
            } actions: {
                Button("groups.addGroup", systemImage: "plus") { prompt = .newGroup }
                    .buttonStyle(.glassProminent)
            }
        case .loaded:
            groupList
        }
    }

    private var groupList: some View {
        List {
            Section {
                Picker("groups.filter.type", selection: $viewModel.typeFilter) {
                    Text("groups.filter.all").tag(TransactionType?.none)
                    Text("transactionType.expense").tag(TransactionType?.some(.expense))
                    Text("transactionType.income").tag(TransactionType?.some(.income))
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }

            ForEach(viewModel.visibleGroups) { group in
                Section {
                    GroupRow(group: group)
                        .contextMenu { groupActions(group) }
                        .swipeActions(edge: .trailing) { groupActions(group) }

                    ForEach(group.categories) { category in
                        CategoryRow(category: category)
                            .contextMenu { categoryActions(category) }
                            .swipeActions(edge: .trailing) { categoryActions(category) }
                    }

                    Button("groups.addCategory", systemImage: "plus") {
                        prompt = .newCategory(groupID: group.id)
                    }
                    .padding(.leading, 20)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    /// Edit always; delete only for a group without categories (`CAT-05`, `CAT-06`).
    @ViewBuilder
    private func groupActions(_ group: GroupWithCategories) -> some View {
        if group.canDelete {
            Button("groups.delete", systemImage: "trash", role: .destructive) {
                pendingDeletion = .group(group)
            }
        }
        Button("groups.edit", systemImage: "pencil") { prompt = .editGroup(group) }
            .tint(.accentColor)
    }

    /// Edit always; delete only for a category without transactions (`CAT-08`, `CAT-09`).
    @ViewBuilder
    private func categoryActions(_ category: GroupWithCategories.Item) -> some View {
        if category.canDelete {
            Button("groups.delete", systemImage: "trash", role: .destructive) {
                pendingDeletion = .category(category)
            }
        }
        Button("groups.edit", systemImage: "pencil") { prompt = .editCategory(category) }
            .tint(.accentColor)
    }

    @ViewBuilder
    private func promptView(_ prompt: Prompt) -> some View {
        switch prompt {
        case .newGroup:
            NamePromptView(
                title: "groups.newGroup",
                failureTitle: "groups.groupCreationFailed",
                type: viewModel.newGroupType
            ) { input in
                try await viewModel.createGroup(name: input.name, type: input.type ?? .expense, color: input.color)
            }
        case .newCategory(let groupID):
            NamePromptView(title: "groups.newCategory", failureTitle: "groups.categoryCreationFailed") { input in
                try await viewModel.createCategory(name: input.name, groupID: groupID, color: input.color)
            }
        case .editGroup(let group):
            NamePromptView(
                title: "groups.editGroup",
                failureTitle: "groups.groupUpdateFailed",
                submitTitle: "groups.save",
                name: group.name,
                color: group.color
            ) { input in
                try await viewModel.updateGroup(id: group.id, name: input.name, color: input.color)
            }
        case .editCategory(let category):
            NamePromptView(
                title: "groups.editCategory",
                failureTitle: "groups.categoryUpdateFailed",
                submitTitle: "groups.save",
                name: category.name,
                color: category.color
            ) { input in
                try await viewModel.updateCategory(id: category.id, name: input.name, color: input.color)
            }
        }
    }

    private func delete(_ deletion: Deletion) async {
        switch deletion {
        case .group(let group): await viewModel.delete(group)
        case .category(let category): await viewModel.delete(category)
        }
    }
}

/// Colour mark, name, type badge and "N categories" (`CAT-02`).
private struct GroupRow: View {
    let group: GroupWithCategories

    var body: some View {
        HStack(spacing: 8) {
            ColorTag(hex: group.color)
            Text(verbatim: group.name)
                .font(.headline)
                .lineLimit(1)
            Text(group.transactionType == .income ? "transactionType.income" : "transactionType.expense")
                .font(.caption.weight(.semibold))
                .foregroundStyle(group.transactionType == .income ? .green : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.fill.tertiary, in: .capsule)
            Spacer(minLength: 8)
            Text("groups.categoryCount \(group.categories.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

/// Colour mark, name and the number of transactions in it (`CAT-03`).
private struct CategoryRow: View {
    let category: GroupWithCategories.Item

    var body: some View {
        HStack(spacing: 8) {
            ColorTag(hex: category.color)
            Text(verbatim: category.name)
                .lineLimit(1)
            Spacer(minLength: 8)
            Text("groups.transactionCount \(category.transactionsCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .padding(.leading, 20)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        GroupsView(app: .preview, isAddingGroup: .constant(false))
    }
    .environment(AppViewModel.preview)
}

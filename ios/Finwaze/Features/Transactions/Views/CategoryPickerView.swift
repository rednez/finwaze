import SwiftUI

/// Picks a group and category in one step-by-step field: groups of the form's type → categories of the group, with a
/// search across all of them (`TX-11`). New groups and categories are created right here (`TX-12`).
struct CategoryPickerView: View {
    private enum Prompt: Identifiable {
        case group
        case category(groupID: Int64)

        var id: String {
            switch self {
            case .group: "group"
            case .category(let groupID): "category-\(groupID)"
            }
        }
    }

    let app: AppViewModel
    @Binding var selection: Category?
    @State private var viewModel: CategoryPickerViewModel
    @State private var path: [Int64] = []
    @State private var prompt: Prompt?
    /// Created while the prompt is open; applied once it has closed.
    @State private var createdGroupID: Int64?
    @State private var createdCategory: Category?
    @Environment(\.dismiss) private var dismiss

    init(type: TransactionType, app: AppViewModel, selection: Binding<Category?>) {
        self.app = app
        _selection = selection
        _viewModel = State(initialValue: CategoryPickerViewModel(type: type, referenceData: app.referenceData))
        // Start inside the group of the current choice, like picking it again.
        _path = State(initialValue: selection.wrappedValue.map { [$0.groupID] } ?? [])
    }

    var body: some View {
        NavigationStack(path: $path) {
            rootList
                .navigationTitle("categoryPicker.title")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(
                    text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: Text("categoryPicker.search")
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.cancel", role: .cancel) { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("categoryPicker.newGroup", systemImage: "folder.badge.plus") { prompt = .group }
                    }
                }
                .navigationDestination(for: Int64.self) { groupID in
                    if let group = viewModel.group(withID: groupID) {
                        GroupCategoriesList(
                            categories: viewModel.categories(in: group),
                            selection: selection,
                            onSelect: select,
                            onNewCategory: { prompt = .category(groupID: group.id) }
                        )
                        .navigationTitle(Text(verbatim: group.name))
                    }
                }
        }
        .sheet(item: $prompt, onDismiss: applyCreated) { prompt in
            switch prompt {
            case .group:
                NamePromptView(title: "categoryPicker.newGroup", failureTitle: "categoryPicker.groupCreationFailed") {
                    createdGroupID = try await app.createGroup(name: $0, type: viewModel.type, color: $1).id
                }
            case .category(let groupID):
                NamePromptView(
                    title: "categoryPicker.newCategory",
                    failureTitle: "categoryPicker.categoryCreationFailed"
                ) {
                    createdCategory = try await app.createCategory(name: $0, groupID: groupID, color: $1)
                }
            }
        }
    }

    @ViewBuilder
    private var rootList: some View {
        if !viewModel.query.trimmingCharacters(in: .whitespaces).isEmpty {
            let results = viewModel.searchResults
            List(results) { result in
                CategoryRow(category: result.category, group: result.group, isSelected: result.id == selection?.id) {
                    select(result.category)
                }
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: viewModel.query)
                }
            }
        } else if viewModel.groups.isEmpty {
            // New users start without categories (`Q-02`): offer to create the first group right here.
            ContentUnavailableView {
                Label("categoryPicker.noGroups.title", systemImage: "folder")
            } description: {
                Text("categoryPicker.noGroups.message")
            } actions: {
                Button("categoryPicker.newGroup", systemImage: "plus") { prompt = .group }
                    .buttonStyle(.glassProminent)
            }
        } else {
            List(viewModel.groups) { group in
                NavigationLink(value: group.id) {
                    HStack(spacing: 8) {
                        ColorTag(hex: group.color)
                        Text(verbatim: group.name)
                        Spacer()
                        Text(verbatim: viewModel.categories(in: group).count.formatted())
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    private func select(_ category: Category) {
        selection = category
        dismiss()
    }

    /// A new group opens so a category can be added to it; a new category is chosen right away. In demo mode
    /// nothing is stored, so neither appears and the picker stays as it is (`AUTH-10`).
    private func applyCreated() {
        if let groupID = createdGroupID, viewModel.group(withID: groupID) != nil {
            path = [groupID]
        }
        if let category = createdCategory, app.referenceData.categories.contains(category) {
            select(category)
        }
        createdGroupID = nil
        createdCategory = nil
    }
}

/// The categories of one group, or an invitation to add the first one.
private struct GroupCategoriesList: View {
    let categories: [Category]
    let selection: Category?
    let onSelect: (Category) -> Void
    let onNewCategory: () -> Void

    var body: some View {
        Group {
            if categories.isEmpty {
                ContentUnavailableView {
                    Label("categoryPicker.noCategories.title", systemImage: "tag")
                } description: {
                    Text("categoryPicker.noCategories.message")
                } actions: {
                    Button("categoryPicker.newCategory", systemImage: "plus", action: onNewCategory)
                        .buttonStyle(.glassProminent)
                }
            } else {
                List(categories) { category in
                    CategoryRow(category: category, group: nil, isSelected: category.id == selection?.id) {
                        onSelect(category)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("categoryPicker.newCategory", systemImage: "plus", action: onNewCategory)
            }
        }
    }
}

/// A category, with its group in search results ("category — group"), and a checkmark on the current choice.
private struct CategoryRow: View {
    let category: Category
    let group: CategoryGroup?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ColorTag(hex: category.color)
                Text(verbatim: category.name)
                    .foregroundStyle(.primary)
                if let group {
                    Text(verbatim: "— \(group.name)")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
            }
            .lineLimit(1)
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    @Previewable @State var selection: Category?
    CategoryPickerView(type: .expense, app: .preview, selection: $selection)
}

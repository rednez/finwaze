import SwiftUI

/// The group filter (`BUD-11`): any number of the month's groups; none picked means every group.
struct BudgetGroupsSheet: View {
    let options: [BudgetItem]
    let filter: BudgetFilter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    row(title: Text("budget.filter.allGroups"), isSelected: filter.groupIDs.isEmpty) {
                        filter.groupIDs = []
                    }
                }
                Section {
                    ForEach(options) { group in
                        row(title: Text(verbatim: group.name), isSelected: filter.groupIDs.contains(group.id)) {
                            toggle(group.id)
                        }
                    }
                }
            }
            .navigationTitle(Text("budget.filter.groups"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.done", role: .confirm) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func row(title: Text, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                title
                    .foregroundStyle(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.tint)
                }
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func toggle(_ id: Int64) {
        if filter.groupIDs.contains(id) {
            filter.groupIDs.remove(id)
        } else {
            filter.groupIDs.insert(id)
        }
    }
}

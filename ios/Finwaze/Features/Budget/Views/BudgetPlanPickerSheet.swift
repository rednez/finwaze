import SwiftUI

/// Picks a group or a category to add to the plan (`BUD-23`, `BUD-24`), with search.
struct BudgetPlanPickerSheet: View {
    struct Option: Identifiable {
        let id: Int64
        let name: String
    }

    let title: LocalizedStringKey
    let options: [Option]
    let onPick: (Int64) -> Void
    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(filtered) { option in
                Button {
                    onPick(option.id)
                    dismiss()
                } label: {
                    Text(verbatim: option.name)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                }
            }
            .overlay {
                if filtered.isEmpty, !query.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle(Text(title))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var filtered: [Option] {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return options }
        return options.filter { $0.name.localizedStandardContains(text) }
    }
}

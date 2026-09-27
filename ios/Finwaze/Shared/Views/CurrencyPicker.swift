import SwiftUI

/// The full currency directory with search by code and name, shown in a sheet (`ONB-02`, `ACC-07`).
struct CurrencyPicker: View {
    let currencies: [Currency]
    @Binding var selection: Currency?
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        let results = currencies.filter { $0.matches(query) }
        NavigationStack {
            List(results) { currency in
                CurrencyRow(currency: currency, isSelected: currency.id == selection?.id) {
                    selection = currency
                    dismiss()
                }
            }
            .overlay {
                if results.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: Text("currencyPicker.search")
            )
            .navigationTitle("currencyPicker.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                }
            }
        }
    }
}

private struct CurrencyRow: View {
    let currency: Currency
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(verbatim: currency.displayName)
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
}

#Preview {
    @Previewable @State var selection: Currency? = DemoData.currencies[1]
    CurrencyPicker(currencies: DemoData.currencies, selection: $selection)
}

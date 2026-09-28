import SwiftUI

/// A currency filter on a card: "USD ⌄" behind a banknote, opening the choice of `currencyCodes`.
struct CurrencyFilterMenu: View {
    /// The filter's name, spoken by VoiceOver and shown on the picker.
    let title: LocalizedStringKey
    let currencyCodes: [String]
    let selection: String
    let onSelect: (String) -> Void

    var body: some View {
        Menu {
            Picker(title, selection: Binding(get: { selection }, set: onSelect)) {
                ForEach(currencyCodes, id: \.self) { code in
                    Text(verbatim: code).tag(code)
                }
            }
        } label: {
            FilterChip(systemImage: "banknote", value: Text(verbatim: selection))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityValue(Text(verbatim: selection))
    }
}

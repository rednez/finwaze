import SwiftUI

/// The primary currency, chosen from the currencies of the user's accounts (`DASH-01`, `GEN-11`, `GEN-17`): its code
/// in the Dashboard's navigation bar opens the list. The Dashboard reloads its cards when the choice changes.
struct PrimaryCurrencyMenu: View {
    @Environment(AppViewModel.self) private var app

    var body: some View {
        let preferences = app.preferences
        let currencyCodes = app.referenceData.sortedAccountCurrencyCodes
        // With a single currency there is nothing to choose.
        if let selection = preferences.primaryCurrencyCode, currencyCodes.count > 1 {
            Menu {
                Picker(
                    "dashboard.currency",
                    selection: Binding(get: { selection }, set: { preferences.primaryCurrencyCode = $0 })
                ) {
                    ForEach(currencyCodes, id: \.self) { code in
                        Text(verbatim: code).tag(code)
                    }
                }
            } label: {
                Text(verbatim: selection)
                    .fontWeight(.semibold)
            }
            .accessibilityLabel(Text("dashboard.currency"))
            .accessibilityValue(Text(verbatim: selection))
        }
    }
}

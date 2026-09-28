import SwiftUI

/// A regular account in the goal's currency (`GOAL-03`), or — when there is none — why, with a way to create one
/// (`Q-04`).
struct GoalAccountField: View {
    let label: LocalizedStringKey
    let accounts: [Account]
    let selection: Account?
    let currencyCode: String
    let error: LocalizedStringResource?
    let onSelect: (Account) -> Void
    let onCreateAccount: () -> Void

    var body: some View {
        if accounts.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Label("goals.noAccount.title \(currencyCode)", systemImage: "exclamationmark.circle")
                    .font(.subheadline.weight(.semibold))
                Text("goals.noAccount.message \(currencyCode)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("goals.noAccount.create", systemImage: "plus", action: onCreateAccount)
                    .buttonStyle(.bordered)
                    .font(.subheadline)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        } else {
            FormField(label: label, error: error) {
                Menu {
                    Picker(label, selection: Binding(get: { selection }, set: { $0.map(onSelect) })) {
                        ForEach(accounts) { account in
                            Text(verbatim: account.name).tag(Account?.some(account))
                        }
                    }
                } label: {
                    PickerRowLabel(
                        value: selection.map { Text(verbatim: $0.name) },
                        placeholder: "transactionForm.accountPlaceholder"
                    )
                }
                .accessibilityValue(selection?.name ?? "")
            }
        }
    }
}

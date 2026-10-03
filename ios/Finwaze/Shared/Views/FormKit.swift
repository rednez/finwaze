import SwiftUI

/// Rows of a form on one rounded card, parted by lines inset to the rows' text like an inset grouped list, with an
/// optional note under it.
struct FormSection<Content: View>: View {
    var footer: Text?
    @ViewBuilder let content: Content

    init(footer: Text? = nil, @ViewBuilder content: () -> Content) {
        self.footer = footer
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(spacing: 0) {
                Group(subviews: content) { rows in
                    ForEach(rows) { row in
                        if row.id != rows.first?.id {
                            Divider()
                                .padding(.leading, FormRowMetrics.textInset)
                        }
                        row
                    }
                }
            }
            .background { CardBackground() }

            if let footer {
                footer
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
            }
        }
    }
}

enum FormRowMetrics {
    static let iconSize: CGFloat = 28
    /// Where a row's text starts: past the padding, the icon and the gap after it.
    static let textInset: CGFloat = 16 + iconSize + 12
}

/// One row of a `FormSection`: an icon on a coloured square, the field's name small above its value — so the value has
/// the row's whole width — an optional note (e.g. an exchange rate) and the validation message under them.
struct FormRow<Value: View>: View {
    let label: LocalizedStringKey
    var systemImage: String?
    var tint: Color = .gray
    var note: Text?
    var error: LocalizedStringResource?
    @ViewBuilder let value: Value

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let systemImage {
                FormRowIcon(systemImage: systemImage, tint: tint)
                    .padding(.top, 4)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                value
                    .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
                if let note {
                    note
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .animation(.default, value: error == nil)
    }
}

/// A row's value picked from a menu: the chosen value — or a placeholder — across the row, an up-down chevron at its
/// end. The whole row opens the menu.
struct FormMenuValue<Value: View, Items: View>: View {
    let value: Value?
    let placeholder: LocalizedStringKey
    @ViewBuilder let items: Items

    var body: some View {
        Menu {
            items
        } label: {
            FormValueLabel(value: value, placeholder: placeholder, systemImage: "chevron.up.chevron.down")
        }
        // The plain style keeps the value in the row's colours instead of the accent.
        .buttonStyle(.plain)
    }
}

/// A row's value: the chosen value, or a placeholder, and a trailing symbol at the row's end.
struct FormValueLabel<Value: View>: View {
    let value: Value?
    let placeholder: LocalizedStringKey
    var systemImage = "chevron.right"

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if let value {
                    value.foregroundStyle(.primary)
                } else {
                    Text(placeholder).foregroundStyle(.tertiary)
                }
            }
            .lineLimit(1)
            Spacer(minLength: 8)
            Image(systemName: systemImage)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .contentShape(.rect)
    }
}

/// An amount field with its currency at the end of the row: the figure in rounded digits, a currency badge or menu.
struct FormAmountInput<Currency: View>: View {
    let title: LocalizedStringKey
    @Binding var text: String
    var keyboard: UIKeyboardType = .decimalPad
    @ViewBuilder let currency: Currency

    var body: some View {
        HStack(spacing: 8) {
            TextField(text: $text, prompt: .zeroAmount) { Text(title) }
                .keyboardType(keyboard)
                .font(.title3.weight(.semibold))
                .fontDesign(.rounded)
                .monospacedDigit()
                .limitsAmountInput($text)
            currency
        }
    }
}

extension View {
    /// Stops a third digit after the decimal separator from being typed or pasted into an amount field (`GEN-07`).
    func limitsAmountInput(_ text: Binding<String>) -> some View {
        // Fixed up after the change rather than in the binding's setter: a setter that keeps the old value leaves the
        // field showing what was typed.
        onChange(of: text.wrappedValue) { _, newValue in
            let limited = AmountInputLimiter.limit(newValue)
            if limited != newValue {
                text.wrappedValue = limited
            }
        }
    }
}

extension FormAmountInput where Currency == CurrencyBadge? {
    /// The amount with its currency's badge, or none while the currency is unknown.
    init(
        title: LocalizedStringKey,
        text: Binding<String>,
        keyboard: UIKeyboardType = .decimalPad,
        currencyCode: String?
    ) {
        self.init(title: title, text: text, keyboard: keyboard) {
            currencyCode.map { CurrencyBadge(code: $0) }
        }
    }
}

/// The white symbol on a rounded square of colour that leads a row, as in Settings.
struct FormRowIcon: View {
    let systemImage: String
    var tint: Color = .gray
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = FormRowMetrics.iconSize

    var body: some View {
        Image(systemName: systemImage)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(tint.gradient, in: .rect(cornerRadius: size * 0.27, style: .continuous))
            .accessibilityHidden(true)
    }
}

extension Text {
    /// "0,00" in the interface language: the empty amount's placeholder.
    static let zeroAmount = Text(verbatim: Decimal.zero.formatted(.number.precision(.fractionLength(2))))
}

/// A destructive action at the end of a form, as a centred row of its own, like "Delete Event" in Calendar.
struct FormDestructiveButton: View {
    let title: LocalizedStringKey
    var isEnabled = true
    let action: () -> Void

    var body: some View {
        FormSection {
            Button(role: .destructive, action: action) {
                Text(title)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .foregroundStyle(isEnabled ? AnyShapeStyle(.red) : AnyShapeStyle(.secondary))
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .disabled(!isEnabled)
        }
    }
}

/// The confirming action of a form in the navigation bar — "Add", "Save" — or a spinner while it runs, where the HIG
/// puts it (Sheets: the confirming action on the trailing side).
struct FormConfirmItem: ToolbarContent {
    let title: LocalizedStringKey
    let isSubmitting: Bool
    var isEnabled = true
    var placement: ToolbarItemPlacement = .confirmationAction
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            if isSubmitting {
                ProgressView()
                    .accessibilityLabel(Text("common.loading"))
            } else {
                Button(title, systemImage: "checkmark", role: .confirm, action: action)
                    .disabled(!isEnabled)
            }
        }
    }
}

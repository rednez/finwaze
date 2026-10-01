import SwiftUI

/// What a screen shows at the moment — "September 2026" with a line of details, e.g. "14 items" or "USD · All
/// statuses" — and the button that opens its filters in a sheet. The period is changed there, not here, so the
/// screen stays calm.
struct FilterSummaryBar: View {
    let title: String
    var details: Text?
    /// Filters set beyond the defaults, shown as a badge on the button.
    var activeCount = 0
    let onFilter: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(action: onFilter) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: title)
                        .font(.title2.weight(.bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                    if let details {
                        details
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityHint(Text("filters.open.hint"))

            Button(action: onFilter) {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.body.weight(.semibold))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .overlay(alignment: .topTrailing) {
                if activeCount > 0 {
                    Text(verbatim: activeCount.formatted())
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 18, minHeight: 18)
                        .background(.tint, in: .capsule)
                        .offset(x: 4, y: -4)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityLabel(Text("filters.open"))
            .accessibilityValue(Text("transactions.filters.activeCount \(activeCount)"))
        }
        // Lines the title up with the text inside the cards below.
        .padding(.horizontal, 4)
        .animation(.snappy, value: title)
    }
}

/// A filters sheet's period row: "‹ September 2026 ›" under its name, the arrows stepping it.
struct FilterPeriodSection<Stepper: View>: View {
    let title: LocalizedStringKey
    @ViewBuilder let stepper: Stepper

    var body: some View {
        Section(title) {
            stepper
                .padding(.vertical, 2)
        }
    }
}

/// The filters sheet's frame shared by every section: a form under "Filters", "Reset" when something can be reset and
/// "Done"; changes apply right away. Half the screen at first, the whole on a swipe.
struct FiltersSheet<Content: View>: View {
    let canReset: Bool
    let onReset: () -> Void
    @ViewBuilder let content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                content
            }
            .navigationTitle("transactions.filters.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("transactions.filters.reset", action: onReset)
                        .disabled(!canReset)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.done", role: .confirm) { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

/// A picker of one of the given currency codes, for a screen's or card's currency.
struct CurrencyCodePicker: View {
    var title: LocalizedStringKey = "wallet.filter.currency"
    let codes: [String]
    let selection: String
    let onSelect: @MainActor (String) -> Void

    var body: some View {
        Picker(title, selection: Binding(get: { selection }, set: onSelect)) {
            ForEach(codes, id: \.self) { code in
                Text(verbatim: code).tag(code)
            }
        }
    }
}

/// A chart card's own settings — its period, currency and the like — behind one small button in the card's header,
/// instead of controls crowding the card. The menu stays open while the period is stepped.
struct ChartSettingsMenu<Extra: View>: View {
    /// "September 2026", the period's header in the menu; `nil` when the chart has no period of its own.
    var periodTitle: String?
    var previousTitle: LocalizedStringKey = "budget.previousMonth"
    var nextTitle: LocalizedStringKey = "budget.nextMonth"
    var onShift: (Int) -> Void = { _ in }
    var currencyCodes: [String] = []
    var currencyCode: String?
    var onSelectCurrency: @MainActor (String) -> Void = { _ in }
    @ViewBuilder var extra: Extra

    var body: some View {
        Menu {
            if let periodTitle {
                Section(periodTitle) {
                    ControlGroup {
                        Button(previousTitle, systemImage: "chevron.left") { shift(-1) }
                        Button(nextTitle, systemImage: "chevron.right") { shift(1) }
                    }
                }
            }
            if let currencyCode, currencyCodes.count > 1 {
                Section("wallet.filter.currency") {
                    CurrencyCodePicker(codes: currencyCodes, selection: currencyCode, onSelect: onSelectCurrency)
                        .pickerStyle(.inline)
                }
            }
            extra
        } label: {
            Image(systemName: "slider.horizontal.3")
                .font(.subheadline.weight(.semibold))
                .frame(width: 22, height: 22)
        }
        .menuActionDismissBehavior(.disabled)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
        .accessibilityLabel(Text("widget.settings"))
    }

    private func shift(_ steps: Int) {
        Haptics.selection()
        withAnimation(.snappy) { onShift(steps) }
    }
}

extension ChartSettingsMenu where Extra == EmptyView {
    init(
        periodTitle: String? = nil,
        previousTitle: LocalizedStringKey = "budget.previousMonth",
        nextTitle: LocalizedStringKey = "budget.nextMonth",
        onShift: @escaping (Int) -> Void = { _ in },
        currencyCodes: [String] = [],
        currencyCode: String? = nil,
        onSelectCurrency: @escaping @MainActor (String) -> Void = { _ in }
    ) {
        self.init(
            periodTitle: periodTitle,
            previousTitle: previousTitle,
            nextTitle: nextTitle,
            onShift: onShift,
            currencyCodes: currencyCodes,
            currencyCode: currencyCode,
            onSelectCurrency: onSelectCurrency
        ) { EmptyView() }
    }
}

extension Text {
    /// "September 2026 · USD": a card's or screen's current choice, parts joined by a middle dot.
    static func summary(_ first: String, _ second: String) -> Text {
        Text("filters.summary \(first) \(second)")
    }
}

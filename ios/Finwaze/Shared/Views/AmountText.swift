import SwiftUI

/// An amount with its currency in the rounded figures of the Wallet and Fitness apps, the cents and the currency a
/// step smaller and quieter than the whole part, so a large sum reads at a glance: **1 250**,00 ₴ (`GEN-06`).
/// Changes roll like a counter.
struct AmountText: View {
    enum Size {
        /// The screen's headline figure, e.g. the Dashboard's total balance.
        case hero
        /// A card's figure, e.g. an account's balance.
        case large
        /// A secondary figure, e.g. income beside expenses.
        case medium

        var font: Font {
            switch self {
            case .hero: .largeTitle.weight(.bold)
            case .large: .title.weight(.bold)
            case .medium: .title2.weight(.semibold)
            }
        }

        var minorFont: Font {
            switch self {
            case .hero: .title2.weight(.semibold)
            case .large: .title3.weight(.semibold)
            case .medium: .headline
            }
        }
    }

    let amount: Decimal
    let currencyCode: String
    var size: Size = .large
    /// A positive amount gets a plus, e.g. an income (`GEN-08`).
    var isSigned = false
    /// The colour of the cents and the currency; on a coloured card, a see-through white.
    var minorColor: Color = .secondary

    var body: some View {
        Text(attributed)
            .font(size.font)
            .fontDesign(.rounded)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .contentTransition(.numericText(value: amount.chartValue))
            .animation(.snappy, value: amount)
    }

    private var attributed: AttributedString {
        var style = Decimal.FormatStyle.Currency(code: currencyCode, locale: .current)
        if isSigned {
            style = style.sign(strategy: .always(showZero: false))
        }
        var text = amount.formatted(style.attributed)
        for run in text.runs {
            let isMinor = run.numberPart == .fraction
                || run.numberSymbol == .decimalSeparator
                || run.numberSymbol == .currency
            if isMinor {
                text[run.range].font = size.minorFont
                text[run.range].foregroundColor = minorColor
            }
        }
        return text
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        AmountText(amount: 12345.67, currencyCode: "UAH", size: .hero)
        AmountText(amount: 3200, currencyCode: "USD")
        AmountText(amount: 850, currencyCode: "EUR", size: .medium, isSigned: true)
    }
    .padding()
}

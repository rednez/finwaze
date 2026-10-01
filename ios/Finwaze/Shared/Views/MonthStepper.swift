import SwiftUI

/// "‹ September 2026 ›": the month between buttons for the previous and the next one (`GEN-14`).
struct MonthStepper: View {
    let month: YearMonth
    let onShift: (Int) -> Void

    var body: some View {
        PeriodStepper(
            title: month.title,
            previousTitle: "budget.previousMonth",
            nextTitle: "budget.nextMonth",
            onShift: onShift
        )
    }
}

/// "‹ 2026 ›": the year between buttons for the previous and the next one (`ANL-04`).
struct YearStepper: View {
    let year: Int
    var previousTitle: LocalizedStringKey = "analytics.previousYear"
    var nextTitle: LocalizedStringKey = "analytics.nextYear"
    let onShift: (Int) -> Void

    var body: some View {
        PeriodStepper(
            // No grouping: "2026", not "2 026".
            title: year.formatted(.number.grouping(.never)),
            previousTitle: previousTitle,
            nextTitle: nextTitle,
            onShift: onShift
        )
    }
}

/// A period between glass buttons that move it back or forward by one.
private struct PeriodStepper: View {
    let title: String
    let previousTitle: LocalizedStringKey
    let nextTitle: LocalizedStringKey
    let onShift: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button(previousTitle, systemImage: "chevron.left") { shift(by: -1) }
            Text(verbatim: title)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
                .frame(maxWidth: .infinity)
            Button(nextTitle, systemImage: "chevron.right") { shift(by: 1) }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }

    private func shift(by steps: Int) {
        Haptics.selection()
        withAnimation(.snappy) { onShift(steps) }
    }
}

extension YearMonth {
    /// "September 2026" in the interface language, capitalised, since some languages write months in lowercase
    /// ("вересень") (`GEN-18`).
    var title: String {
        guard let start = start(in: .current) else { return "" }
        let text = start.formattedMonth()
        return text.prefix(1).uppercased() + text.dropFirst()
    }
}

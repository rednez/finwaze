import SwiftUI

/// "‹ September 2026 ›": the month between buttons for the previous and the next one (`GEN-14`).
struct MonthStepper: View {
    let month: YearMonth
    var font: Font = .title3.weight(.semibold)
    let onShift: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Button("budget.previousMonth", systemImage: "chevron.left") { shift(by: -1) }
            Text(verbatim: month.title)
                .font(font)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())
                .frame(maxWidth: .infinity)
            Button("budget.nextMonth", systemImage: "chevron.right") { shift(by: 1) }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.glass)
        .buttonBorderShape(.circle)
    }

    private func shift(by months: Int) {
        withAnimation(.snappy) { onShift(months) }
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

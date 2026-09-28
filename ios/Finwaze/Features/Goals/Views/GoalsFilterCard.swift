import SwiftUI

/// The Goals filters (`GOAL-10`): "‹ 2026 ›" — goals due from 1 January of that year — and the status.
struct GoalsFilterCard: View {
    let viewModel: GoalsViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Button("goals.filter.previousYear", systemImage: "chevron.left") { shiftYear(by: -1) }
                Text(verbatim: String(viewModel.year))
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel(Text("goals.filter.year \(String(viewModel.year))"))
                Button("goals.filter.nextYear", systemImage: "chevron.right") { shiftYear(by: 1) }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)

            Menu {
                Picker("goals.filter.status", selection: Binding(
                    get: { viewModel.status },
                    set: { viewModel.status = $0 }
                )) {
                    Text("goals.filter.allStatuses").tag(SavingsGoalStatus?.none)
                    ForEach(SavingsGoalStatus.allCases, id: \.self) { status in
                        Label {
                            Text(status.title)
                        } icon: {
                            Image(systemName: status.systemImage)
                        }
                        .tag(SavingsGoalStatus?.some(status))
                    }
                }
            } label: {
                FilterChip(systemImage: viewModel.status?.systemImage ?? "circle.dashed", value: statusText)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel(Text("goals.filter.status"))
            .accessibilityValue(statusText)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 28))
    }

    private var statusText: Text {
        viewModel.status.map { Text($0.title) } ?? Text("goals.filter.allStatuses")
    }

    private func shiftYear(by years: Int) {
        withAnimation(.snappy) { viewModel.shiftYear(by: years) }
    }
}

import SwiftUI

/// "Total goals": how many goals the filters show, and how many in each status (`GOAL-15`).
struct GoalsSummaryCard: View {
    let state: CardState<GoalsSummary>
    let onRetry: () -> Void

    var body: some View {
        ContentCard(title: "goals.summary.title") {
            CardStateView(state: state, placeholder: GoalsSummary([]), onRetry: onRetry) { summary in
                VStack(alignment: .leading, spacing: 12) {
                    Text(summary.total, format: .number)
                        .font(.largeTitle.weight(.semibold))
                        .monospacedDigit()
                        .accessibilityLabel(Text("goals.summary.total \(summary.total)"))
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 8)], spacing: 8) {
                        ForEach(SavingsGoalStatus.allCases, id: \.self) { status in
                            StatusCount(status: status, count: summary.count(status))
                        }
                    }
                }
            }
        }
    }
}

/// One status with its colour and count, e.g. "● In progress  2".
private struct StatusCount: View {
    let status: SavingsGoalStatus
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: status.systemImage)
                .foregroundStyle(status.color)
                .accessibilityHidden(true)
            Text(status.title)
                .font(.subheadline)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text(count, format: .number)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(status.color.opacity(0.1), in: .capsule)
        .accessibilityElement(children: .combine)
    }
}

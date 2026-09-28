import SwiftUI

/// "Savings goals": the three newest with their progress; a goal or the link opens Goals (`DASH-07`).
struct SavingsGoalsCard: View {
    let state: CardState<[SavingsGoal]>
    let onRetry: () -> Void
    let onOpenGoals: () -> Void

    var body: some View {
        ContentCard(
            title: "dashboard.goals.title",
            action: .init(title: "dashboard.goals.all", perform: onOpenGoals)
        ) {
            CardStateView(state: state, placeholder: .placeholder, onRetry: onRetry) { goals in
                if goals.isEmpty {
                    CardEmptyState(
                        title: "dashboard.goals.empty.title",
                        message: "dashboard.goals.empty.message",
                        actionTitle: "dashboard.goals.open",
                        action: onOpenGoals
                    )
                } else {
                    VStack(spacing: 16) {
                        ForEach(goals) { goal in
                            Button(action: onOpenGoals) {
                                GoalProgressRow(goal: goal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

/// Name, percentage, bar and "saved / target", each amount with its currency (`GEN-06`).
private struct GoalProgressRow: View {
    let goal: SavingsGoal

    private var percent: String {
        (Decimal(goal.progressPercent) / 100).formatted(.percent.precision(.fractionLength(0)))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: goal.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(verbatim: percent)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.tint)
            }
            ProgressView(value: goal.progressFraction)
                .accessibilityHidden(true)
            Text(
                "dashboard.goals.progress \(goal.accumulatedAmount.formattedAmount(currencyCode: goal.currencyCode)) \(goal.targetAmount.formattedAmount(currencyCode: goal.currencyCode))"
            )
            .font(.footnote)
            .monospacedDigit()
            .foregroundStyle(.secondary)
        }
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
    }
}

private extension [SavingsGoal] {
    /// Skeleton goals while they load (`GEN-23`).
    static var placeholder: [SavingsGoal] {
        DemoData.savingsGoals()
    }
}

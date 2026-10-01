import SwiftUI

/// A goal on Goals (`GOAL-11`, `GOAL-12`): status, name, due date, saved of target, progress and, for a goal in
/// progress, what is left. The card opens the goal; "Deposit" and "Withdraw" sit under it when they apply.
struct GoalCard: View {
    let goal: SavingsGoal
    let onOpen: () -> Void
    let onDeposit: () -> Void
    let onWithdraw: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: onOpen) {
                GoalCardSummary(goal: goal)
            }
            .buttonStyle(.plain)
            .accessibilityHint(Text("goals.card.openHint"))

            if goal.canDeposit {
                HStack(spacing: 8) {
                    Button("goals.deposit", systemImage: "arrow.down.circle", action: onDeposit)
                        .buttonStyle(.glassProminent)
                    if goal.canWithdraw {
                        Button("goals.withdraw", systemImage: "arrow.up.circle", action: onWithdraw)
                            .buttonStyle(.glass)
                    }
                }
                .font(.subheadline.weight(.medium))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background { CardBackground() }
    }
}

/// Everything on the card but its actions, read by VoiceOver as one element.
struct GoalCardSummary: View {
    let goal: SavingsGoal

    private var percent: String {
        (Decimal(goal.progressPercent) / 100).formatted(.percent.precision(.fractionLength(0)))
    }

    private var saved: String {
        goal.accumulatedAmount.formattedAmount(currencyCode: goal.currencyCode)
    }

    private var target: String {
        goal.targetAmount.formattedAmount(currencyCode: goal.currencyCode)
    }

    private var dueDate: String {
        goal.targetDate.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: goal.name)
                        .font(.headline)
                        .lineLimit(2)
                    Text("goals.card.due \(dueDate)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                GoalStatusBadge(status: goal.status)
            }

            HStack(spacing: 16) {
                ProgressRing(fraction: goal.progressFraction, tint: goal.status.color)
                VStack(alignment: .leading, spacing: 2) {
                    AmountText(amount: goal.accumulatedAmount, currencyCode: goal.currencyCode, size: .large)
                    Text("goals.card.ofTarget \(target)")
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                    if goal.status == .inProgress {
                        Text("goals.card.left \(goal.remainingAmount.formattedAmount(currencyCode: goal.currencyCode))")
                            .font(.footnote)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .contentShape(.rect)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: goal.name))
        .accessibilityValue(accessibilityValue)
    }

    /// "In progress, 5 800 $ of 10 000 $, 58 %, due 31 May 2027".
    private var accessibilityValue: Text {
        Text("goals.card.accessibility \(String(localized: goal.status.title)) \(saved) \(target) \(percent) \(dueDate)")
    }
}

#Preview {
    GoalCard(goal: DemoData.savingsGoals()[0], onOpen: {}, onDeposit: {}, onWithdraw: {})
        .padding()
        .background(Color(.systemGroupedBackground))
}

import SwiftUI

extension SavingsGoalStatus {
    /// "Not started", "In progress", "Done", "Cancelled" — the filter's and the badge's text (`GOAL-02`).
    var title: LocalizedStringResource {
        switch self {
        case .notStarted: "goals.status.notStarted"
        case .inProgress: "goals.status.inProgress"
        case .done: "goals.status.done"
        case .cancelled: "goals.status.cancelled"
        }
    }

    /// The web's status colours: amber, green, the accent and red (`GOAL-11`).
    var color: Color {
        switch self {
        case .notStarted: .orange
        case .inProgress: .green
        case .done: .accentColor
        case .cancelled: .red
        }
    }

    var systemImage: String {
        switch self {
        case .notStarted: "circle.dashed"
        case .inProgress: "arrow.up.circle"
        case .done: "checkmark.circle"
        case .cancelled: "xmark.circle"
        }
    }
}

/// A goal's status as a coloured capsule with its name, so it never relies on colour alone (`GOAL-11`).
struct GoalStatusBadge: View {
    let status: SavingsGoalStatus

    var body: some View {
        Label {
            Text(status.title)
        } icon: {
            Image(systemName: status.systemImage)
        }
            .font(.caption.weight(.semibold))
            .foregroundStyle(status.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.15), in: .capsule)
    }
}

#Preview {
    VStack {
        ForEach(SavingsGoalStatus.allCases, id: \.self) { GoalStatusBadge(status: $0) }
    }
}

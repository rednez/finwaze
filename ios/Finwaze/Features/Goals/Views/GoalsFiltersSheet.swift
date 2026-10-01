import SwiftUI

/// The Goals filters in a bottom sheet (`GOAL-10`): the year — goals due from 1 January of it — and the status.
/// "Reset" brings back every status and leaves the year.
struct GoalsFiltersSheet: View {
    let viewModel: GoalsViewModel

    var body: some View {
        FiltersSheet(canReset: viewModel.activeFilterCount > 0, onReset: { viewModel.status = nil }) {
            FilterPeriodSection(title: "filters.year") {
                YearStepper(
                    year: viewModel.year,
                    previousTitle: "goals.filter.previousYear",
                    nextTitle: "goals.filter.nextYear",
                    onShift: viewModel.shiftYear(by:)
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text("goals.filter.year \(String(viewModel.year))"))
            }

            Section {
                Picker("goals.filter.status", selection: Binding(
                    get: { viewModel.status },
                    set: { viewModel.status = $0 }
                )) {
                    Text("goals.filter.allStatuses").tag(SavingsGoalStatus?.none)
                    ForEach(SavingsGoalStatus.allCases, id: \.self) { status in
                        Label(status.title, systemImage: status.systemImage).tag(SavingsGoalStatus?.some(status))
                    }
                }
            }
        }
    }
}

extension GoalsViewModel {
    /// The status set beyond "All statuses"; the year always has a value.
    var activeFilterCount: Int {
        status == nil ? 0 : 1
    }

    var statusText: Text {
        status.map { Text($0.title) } ?? Text("goals.filter.allStatuses")
    }
}

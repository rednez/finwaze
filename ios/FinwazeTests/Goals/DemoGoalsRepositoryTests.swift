import Foundation
import Testing
@testable import Finwaze

/// The demo Goals serve `DemoData` and change nothing (`AUTH-10`).
struct DemoGoalsRepositoryTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    /// 16 September 2026: the demo goals are due in January 2027 and May 2027.
    private var repository: DemoGoalsRepository {
        let now = calendar.date(from: DateComponents(year: 2026, month: 9, day: 16, hour: 18))!
        return DemoGoalsRepository(calendar: calendar, now: { now })
    }

    @Test func filtersByYearAndStatus() async throws {
        #expect(try await repository.goals(GoalsQuery(year: 2026, status: nil)).map(\.id) == [101, 102])
        #expect(try await repository.goals(GoalsQuery(year: 2027, status: .inProgress)).map(\.id) == [101, 102])
        #expect(try await repository.goals(GoalsQuery(year: 2026, status: .done)).isEmpty)
        #expect(try await repository.goals(GoalsQuery(year: 2028, status: nil)).isEmpty)
    }

    @Test func findsAGoal() async throws {
        #expect(try await repository.goal(id: 102)?.name == "Vacation")
        #expect(try await repository.goal(id: 1) == nil)
    }

    @Test func overviewForTheGoalsCurrencies() async throws {
        let usd = try await repository.savingsOverview(year: 2026, currencyCode: "USD")
        #expect(usd.count == 12)
        #expect(usd.first == MonthlySavings(month: YearMonth(year: 2026, month: 1), currentYear: 200, previousYear: 150))
        #expect(usd.last?.currentYear == 530)

        let uah = try await repository.savingsOverview(year: 2026, currencyCode: "UAH")
        #expect(uah.allSatisfy { $0.currentYear == 0 && $0.previousYear == 0 })
    }

    @Test func writesChangeNothing() async throws {
        let day = calendar.date(from: DateComponents(year: 2027, month: 1, day: 1))!
        let id = try await repository.create(NewSavingsGoal(name: "Car", currencyID: 1, targetAmount: 100, targetDate: day))
        try await repository.markDone(id: 101)
        try await repository.cancel(id: 102)
        try await repository.delete(id: 101)

        #expect(id == DemoGoalsRepository.createdGoalID)
        #expect(try await repository.goals(GoalsQuery(year: 2026, status: nil)).map(\.status) == [.inProgress, .inProgress])
    }
}

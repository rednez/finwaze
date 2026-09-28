import Foundation
import Testing
@testable import Finwaze

struct SavingsGoalsMapperTests {
    private let kyiv = TimeZone(identifier: "Europe/Kyiv")!

    private func row(status: String = "in_progress", target: String = "10000", saved: String = "5800") -> String {
        """
        {"id": 101, "name": "Emergency Fund", "currency_code": "USD", "target_date": "2027-05-31",
         "status": "\(status)", "target_amount": \(target), "accumulated_amount": \(saved), "has_transfers": true}
        """
    }

    private func map(_ json: String) throws -> SavingsGoal {
        try SavingsGoalsMapper.toGoal(JSONDecoder().decode(SavingsGoalDto.self, from: Data(json.utf8)), timeZone: kyiv)
    }

    @Test func mapsRow() throws {
        let goal = try map(row())

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = kyiv
        #expect(goal.id == 101)
        #expect(goal.currencyCode == "USD")
        #expect(goal.status == .inProgress)
        #expect(goal.targetAmount == 10000)
        #expect(goal.accumulatedAmount == 5800)
        #expect(goal.hasTransfers)
        #expect(calendar.dateComponents([.year, .month, .day, .hour], from: goal.targetDate)
            == DateComponents(year: 2027, month: 5, day: 31, hour: 0))
    }

    @Test(arguments: [
        ("not_started", SavingsGoalStatus.notStarted),
        ("in_progress", .inProgress),
        ("done", .done),
        ("cancelled", .cancelled),
    ])
    func mapsStatus(_ raw: String, _ status: SavingsGoalStatus) throws {
        #expect(try map(row(status: raw)).status == status)
    }

    @Test func rejectsAnUnreadableDate() throws {
        let dto = try JSONDecoder().decode(SavingsGoalDto.self, from: Data(row().replacing("2027-05-31", with: "soon").utf8))

        #expect(throws: SavingsGoalsMapper.MappingError.invalidDate("soon")) {
            try SavingsGoalsMapper.toGoal(dto)
        }
    }

    /// Rounded down like the web; the bar stops at full while the percentage may exceed 100.
    @Test(arguments: [
        ("10000", "5800", 58, 0.58),
        ("3", "2", 66, 0.66),
        ("100", "0", 0, 0.0),
        ("100", "150.5", 150, 1.0),
        ("0", "10", 0, 0.0),
    ])
    func progress(_ target: String, _ saved: String, _ percent: Int, _ fraction: Double) throws {
        let goal = try map(row(target: target, saved: saved))

        #expect(goal.progressPercent == percent)
        #expect(goal.progressFraction == fraction)
    }

    // MARK: Savings overview (GOAL-16)

    @Test func mapsAnOverviewMonth() throws {
        let json = #"{"month": "2026-03-01", "current_year_amount": -50.25, "previous_year_amount": null}"#
        let month = try SavingsGoalsMapper.toMonthlySavings(JSONDecoder().decode(MonthlySavingsDto.self, from: Data(json.utf8)))

        #expect(month == MonthlySavings(month: YearMonth(year: 2026, month: 3), currentYear: Decimal(string: "-50.25")!, previousYear: 0))
    }

    @Test func rejectsAnUnreadableMonth() throws {
        let dto = MonthlySavingsDto(month: "March", currentYearAmount: 1, previousYearAmount: 1)

        #expect(throws: SavingsGoalsMapper.MappingError.invalidDate("March")) {
            try SavingsGoalsMapper.toMonthlySavings(dto)
        }
    }

    // MARK: Parameters (GOAL-20)

    /// The date goes as the calendar day on this device, the amount exactly (`GEN-09`).
    @Test func encodesANewGoal() throws {
        let day = try #require(SavingsGoalsMapper.parseDate("2027-05-31", timeZone: kyiv))
        let goal = NewSavingsGoal(name: "Vacation", currencyID: 2, targetAmount: Decimal(string: "30000.1")!, targetDate: day)

        let json = try #require(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(SavingsGoalsMapper.toDto(goal, timeZone: kyiv)))
                as? [String: Any]
        )

        #expect(json["p_name"] as? String == "Vacation")
        #expect(json["p_currency_id"] as? Int == 2)
        #expect((json["p_target_amount"] as? NSNumber)?.decimalValue == Decimal(string: "30000.1"))
        #expect(json["p_target_date"] as? String == "2027-05-31")
    }

    @Test func encodesAnUpdate() throws {
        let day = try #require(SavingsGoalsMapper.parseDate("2027-01-01", timeZone: kyiv))
        let update = SavingsGoalUpdate(name: "Car", targetAmount: 1500, targetDate: day)

        let json = try #require(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(SavingsGoalsMapper.toDto(id: 7, update, timeZone: kyiv)))
                as? [String: Any]
        )

        #expect(json["p_account_id"] as? Int == 7)
        #expect(json["p_name"] as? String == "Car")
        #expect((json["p_target_amount"] as? NSNumber)?.decimalValue == 1500)
        #expect(json["p_target_date"] as? String == "2027-01-01")
        #expect(json["p_currency_id"] == nil)
    }

    @Test func periodStartsOnTheFirstOfJanuary() {
        #expect(GoalsQuery(year: 2026, status: nil).periodFromParameter == "2026-01-01")
    }

    // MARK: Actions (GOAL-12, GOAL-23…25)

    @Test func actionsFollowTheStatusAndTheSavedAmount() {
        let notStarted = SavingsGoal.fixture(status: .notStarted, saved: 0, hasTransfers: false)
        #expect(notStarted.canDeposit && !notStarted.canWithdraw && notStarted.canCancel && notStarted.canDelete)
        #expect(!notStarted.canMarkDone)

        let inProgress = SavingsGoal.fixture(status: .inProgress, target: 1000, saved: 400)
        #expect(inProgress.canDeposit && inProgress.canWithdraw && !inProgress.canMarkDone && !inProgress.canDelete)
        #expect(inProgress.remainingAmount == 600)

        let reached = SavingsGoal.fixture(status: .inProgress, target: 1000, saved: 1200)
        #expect(reached.canMarkDone)
        #expect(reached.remainingAmount == 0)

        for status in [SavingsGoalStatus.done, .cancelled] {
            let finished = SavingsGoal.fixture(status: status, target: 1000, saved: 1000)
            #expect(!finished.canDeposit && !finished.canWithdraw && !finished.canMarkDone && !finished.canCancel)
        }
    }

    @Test func summaryCountsByStatus() {
        let summary = GoalsSummary([
            .fixture(id: 1, status: .inProgress),
            .fixture(id: 2, status: .inProgress),
            .fixture(id: 3, status: .done),
        ])

        #expect(summary.total == 3)
        #expect(summary.count(.inProgress) == 2)
        #expect(summary.count(.done) == 1)
        #expect(summary.count(.notStarted) == 0)
    }
}

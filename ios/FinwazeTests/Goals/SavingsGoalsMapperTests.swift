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
}

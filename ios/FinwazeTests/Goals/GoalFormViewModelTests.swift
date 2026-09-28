import Foundation
import Testing
@testable import Finwaze

@MainActor
struct GoalFormViewModelTests {
    private let repository = FakeGoalsRepository()
    /// 27 September 2026, 12:15 in Kyiv.
    private let now = Date(timeIntervalSince1970: 1_790_500_500)
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kyiv")!
        return calendar
    }()

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    private func makeViewModel(
        _ mode: GoalFormViewModel.Mode,
        defaultCurrency: String? = "UAH",
        onSaved: @escaping () async -> Void = {}
    ) async throws -> GoalFormViewModel {
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository())
        let now = now
        return GoalFormViewModel(
            mode: mode,
            referenceData: referenceData,
            repository: repository,
            defaultCurrencyCode: defaultCurrency,
            clock: { now },
            calendar: calendar,
            locale: Locale(identifier: "en_US"),
            onSaved: onSaved
        )
    }

    // MARK: New goal (GOAL-20, GOAL-21)

    @Test func newGoalStartsWithThePrimaryCurrencyAndNoDate() async throws {
        let viewModel = try await makeViewModel(.create)

        #expect(viewModel.currency == FakeReferenceDataRepository.uah)
        #expect(viewModel.targetDate == nil)
        #expect(!viewModel.isEditing)
        #expect(!viewModel.isReadOnly)
    }

    @Test func createsTheGoal() async throws {
        var saved = false
        let viewModel = try await makeViewModel(.create) { saved = true }
        viewModel.name = "  Vacation "
        viewModel.targetAmountText = "30000"
        viewModel.targetDate = calendar.date(byAdding: .hour, value: 15, to: day(2027, 6, 1))
        viewModel.currency = FakeReferenceDataRepository.eur

        #expect(await viewModel.submit())

        #expect(repository.created == [
            NewSavingsGoal(name: "Vacation", currencyID: FakeReferenceDataRepository.eur.id, targetAmount: 30000,
                           targetDate: day(2027, 6, 1)),
        ])
        #expect(saved)
    }

    @Test(arguments: ["Ab", String(repeating: "a", count: 31), "   "])
    func nameMustBe3To30Characters(_ name: String) async throws {
        let viewModel = try await makeViewModel(.create)
        viewModel.name = name

        #expect(await !viewModel.submit())
        #expect(viewModel.nameIssue == .length)
    }

    @Test func targetIsAtLeastOne() async throws {
        let viewModel = try await makeViewModel(.create)
        viewModel.targetAmountText = "0.5"
        #expect(await !viewModel.submit())
        #expect(viewModel.amountIssue == .belowMinimum)

        viewModel.targetAmountText = ""
        #expect(viewModel.amountIssue == .input(.required))

        viewModel.targetAmountText = "1"
        #expect(viewModel.amountIssue == nil)
    }

    @Test func dateIsRequiredAndNotInThePast() async throws {
        let viewModel = try await makeViewModel(.create)
        #expect(await !viewModel.submit())
        #expect(viewModel.dateIssue == .required)

        viewModel.targetDate = day(2026, 9, 26)
        #expect(viewModel.dateIssue == .inPast)

        viewModel.targetDate = day(2026, 9, 27)
        #expect(viewModel.dateIssue == nil)
    }

    @Test func currencyIsRequired() async throws {
        let viewModel = try await makeViewModel(.create, defaultCurrency: nil)

        #expect(await !viewModel.submit())
        #expect(viewModel.currencyIssue == .required)
    }

    @Test func failureKeepsTheForm() async throws {
        let viewModel = try await makeViewModel(.create)
        viewModel.name = "Vacation"
        viewModel.targetAmountText = "100"
        viewModel.targetDate = day(2027, 1, 1)
        repository.setFails(.create)

        #expect(await !viewModel.submit())
        #expect(viewModel.failure == "duplicate key value")
        #expect(viewModel.name == "Vacation")
    }

    // MARK: Editing (GOAL-20, GOAL-22)

    @Test func editingFillsTheGoalAndLocksTheCurrency() async throws {
        let goal = SavingsGoal.fixture(currencyCode: "EUR", targetDate: day(2027, 5, 31), target: Decimal(string: "1500.5")!)
        let viewModel = try await makeViewModel(.edit(goal))

        #expect(viewModel.name == "Vacation")
        #expect(viewModel.targetAmountText == "1500.50")
        #expect(viewModel.targetDate == day(2027, 5, 31))
        #expect(viewModel.currencyCode == "EUR")
        #expect(viewModel.isEditing)
        #expect(!viewModel.hasChanges)
    }

    @Test func savesChanges() async throws {
        let goal = SavingsGoal.fixture(id: 7, targetDate: day(2027, 5, 31), target: 1000)
        let viewModel = try await makeViewModel(.edit(goal))
        viewModel.targetAmountText = "1200"
        #expect(viewModel.hasChanges)

        #expect(await viewModel.submit())

        #expect(repository.updated.map(\.id) == [7])
        #expect(repository.updated.first?.update == SavingsGoalUpdate(name: "Vacation", targetAmount: 1200, targetDate: day(2027, 5, 31)))
    }

    @Test func changingBackIsNoChange() async throws {
        let goal = SavingsGoal.fixture(targetDate: day(2027, 5, 31), target: 1000)
        let viewModel = try await makeViewModel(.edit(goal))

        viewModel.name = "Car"
        viewModel.name = "Vacation"
        viewModel.targetDate = calendar.date(byAdding: .hour, value: 10, to: day(2027, 5, 31))

        #expect(!viewModel.hasChanges)
    }

    /// An overdue goal can be renamed without moving its date.
    @Test func overdueDateMayStay() async throws {
        let goal = SavingsGoal.fixture(targetDate: day(2026, 3, 1))
        let viewModel = try await makeViewModel(.edit(goal))
        viewModel.name = "Old vacation"

        #expect(viewModel.earliestDate == day(2026, 3, 1))
        #expect(await viewModel.submit())

        viewModel.targetDate = day(2026, 2, 1)
        #expect(viewModel.dateIssue == .inPast)
    }

    @Test(arguments: [SavingsGoalStatus.done, .cancelled])
    func finishedGoalIsReadOnly(_ status: SavingsGoalStatus) async throws {
        let viewModel = try await makeViewModel(.edit(.fixture(status: status)))
        viewModel.name = "Changed"

        #expect(viewModel.isReadOnly)
        #expect(await !viewModel.submit())
        #expect(repository.updated.isEmpty)
    }
}

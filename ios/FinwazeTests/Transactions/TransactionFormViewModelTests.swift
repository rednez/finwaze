import Foundation
import Testing
@testable import Finwaze

@MainActor
struct TransactionFormViewModelTests {
    private let cash = Account(id: 1, name: "Cash", currencyCode: "UAH")
    private let card = Account(id: 2, name: "Card", currencyCode: "EUR")
    private let now = Date(timeIntervalSince1970: 1_790_500_500)
    private let preferences = DevicePreferences(defaults: makeTestDefaults())
    private let repository = FakeTransactionsRepository()

    private func makeViewModel(
        repository: (any TransactionsRepository)? = nil,
        onCreated: @escaping () async -> Void = {}
    ) async throws -> TransactionFormViewModel {
        let referenceData = try await makeReferenceData(
            FakeReferenceDataRepository(
                accounts: [cash, card],
                groups: [FakeReferenceDataRepository.food, FakeReferenceDataRepository.salary],
                categories: [FakeReferenceDataRepository.groceries, FakeReferenceDataRepository.paycheck]
            )
        )
        return TransactionFormViewModel(
            referenceData: referenceData,
            preferences: preferences,
            repository: repository ?? self.repository,
            now: now,
            onCreated: onCreated
        )
    }

    private func fill(_ viewModel: TransactionFormViewModel, amount: String = "250") {
        viewModel.account = cash
        viewModel.amountText = amount
        viewModel.category = FakeReferenceDataRepository.groceries
    }

    @Test func startsAsExpenseNow() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.type == .expense)
        #expect(viewModel.transactedAt == now)
        #expect(viewModel.account == nil)
        #expect(viewModel.category == nil)
    }

    @Test func hidesErrorsUntilSubmit() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.accountIssue == nil)
        #expect(viewModel.amountIssue == nil)
        #expect(viewModel.categoryIssue == nil)
    }

    @Test func requiresAccountAmountAndCategory() async throws {
        let viewModel = try await makeViewModel()

        #expect(await viewModel.submit() == false)

        #expect(viewModel.accountIssue == .required)
        #expect(viewModel.amountIssue == .required)
        #expect(viewModel.categoryIssue == .required)
        #expect(repository.created.isEmpty)
    }

    @Test(arguments: [
        ("0", TransactionFormViewModel.AmountIssue.notPositive),
        ("0,00", .notPositive),
        ("-5", .notPositive),
        ("abc", .notPositive),
        ("1,234", .tooPrecise),
    ])
    func rejectsBadAmounts(_ text: String, issue: TransactionFormViewModel.AmountIssue) async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel, amount: text)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.amountIssue == issue)
        #expect(repository.created.isEmpty)
    }

    @Test func commentIsAtMostHundredCharacters() async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel)
        viewModel.comment = String(repeating: "a", count: 101)

        #expect(await viewModel.submit() == false)
        #expect(viewModel.commentIssue == .tooLong)

        viewModel.comment = String(repeating: "a", count: 100)
        #expect(await viewModel.submit())
    }

    /// `TX-23`, `TX-24`: a positive amount in the account's currency, charged as entered.
    @Test func createsExpenseInAccountCurrency() async throws {
        var createdCalls = 0
        let viewModel = try await makeViewModel { createdCalls += 1 }
        fill(viewModel, amount: "250,5")
        viewModel.comment = "  Lunch  "

        #expect(await viewModel.submit())

        let expected = NewTransaction(
            type: .expense,
            transactedAt: now,
            localOffset: LocalOffset.current(at: now),
            accountID: cash.id,
            categoryID: FakeReferenceDataRepository.groceries.id,
            transactionAmount: Decimal(string: "250.5")!,
            transactionCurrencyID: FakeReferenceDataRepository.uah.id,
            chargedAmount: Decimal(string: "250.5")!,
            comment: "Lunch"
        )
        #expect(repository.created == [expected])
        #expect(createdCalls == 1)
        #expect(!viewModel.isSubmitting)
    }

    @Test func purchaseCurrencyFollowsTheAccount() async throws {
        let viewModel = try await makeViewModel()

        viewModel.account = cash
        #expect(viewModel.purchaseCurrencyCode == "UAH")

        viewModel.account = card
        #expect(viewModel.purchaseCurrencyCode == "EUR")
    }

    @Test func emptyCommentIsSentAsNone() async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel)
        viewModel.comment = "   "

        #expect(await viewModel.submit())

        #expect(repository.created.first?.comment == nil)
    }

    // MARK: Remembered choices (TX-16)

    @Test func secondExpenseStartsWithThePreviousChoices() async throws {
        let first = try await makeViewModel()
        fill(first)
        #expect(await first.submit())

        let second = try await makeViewModel()

        #expect(second.account == cash)
        #expect(second.category == FakeReferenceDataRepository.groceries)
        #expect(preferences.expenseDefaults?.currencyCode == "UAH")
        #expect(second.amountText.isEmpty)
    }

    @Test func expenseAndIncomeAreRememberedSeparately() async throws {
        let income = try await makeViewModel()
        income.type = .income
        income.account = card
        income.amountText = "1000"
        income.category = FakeReferenceDataRepository.paycheck
        #expect(await income.submit())
        #expect(preferences.incomeDefaults?.currencyCode == nil)

        let form = try await makeViewModel()
        #expect(form.account == nil)
        #expect(form.category == nil)

        form.type = .income
        #expect(form.account == card)
        #expect(form.category == FakeReferenceDataRepository.paycheck)
    }

    @Test func switchingTypeDropsCategoryOfTheOtherType() async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel)

        viewModel.type = .income

        #expect(viewModel.category == nil)
        #expect(viewModel.account == cash)
        #expect(viewModel.amountText == "250")
    }

    @Test func skipsRememberedChoicesThatNoLongerExist() async throws {
        preferences.expenseDefaults = TransactionFormDefaults(accountID: 99, groupID: 1, categoryID: 99, currencyCode: "USD")

        let viewModel = try await makeViewModel()

        #expect(viewModel.account == nil)
        #expect(viewModel.category == nil)
    }

    // MARK: Feedback (GEN-19, GEN-20)

    @Test func failureKeepsTheFormData() async throws {
        repository.setCreateFails(true)
        var createdCalls = 0
        let viewModel = try await makeViewModel { createdCalls += 1 }
        fill(viewModel)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.failure == "duplicate key value")
        #expect(viewModel.amountText == "250")
        #expect(viewModel.category == FakeReferenceDataRepository.groceries)
        #expect(createdCalls == 0)
        #expect(preferences.expenseDefaults == nil)
    }

    @Test func ignoresSubmitWhileCreating() async throws {
        let repository = SuspendedTransactionsRepository()
        let viewModel = try await makeViewModel(repository: repository)
        fill(viewModel)

        let first = Task { await viewModel.submit() }
        await repository.waitUntilCalled()
        #expect(viewModel.isSubmitting)

        #expect(await viewModel.submit() == false)

        repository.resume()
        #expect(await first.value)
        #expect(repository.createCalls == 1)
        #expect(!viewModel.isSubmitting)
    }
}

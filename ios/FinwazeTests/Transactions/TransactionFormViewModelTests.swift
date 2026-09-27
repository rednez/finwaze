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
        mode: TransactionFormViewModel.Mode = .create,
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
            mode: mode,
            referenceData: referenceData,
            preferences: preferences,
            repository: repository ?? self.repository,
            now: now,
            onSaved: onCreated
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

    // MARK: Purchase currency and charged amount (TX-21, TX-22, GEN-10)

    @Test func purchaseCurrencyCodesAreTheAccountsCurrencies() async throws {
        let viewModel = try await makeViewModel()

        #expect(viewModel.purchaseCurrencyCodes == ["UAH", "EUR"])
    }

    @Test func changingAccountResetsThePurchaseCurrencyToItsOwn() async throws {
        let viewModel = try await makeViewModel()
        viewModel.account = cash
        viewModel.purchaseCurrencyCode = "EUR"
        viewModel.chargedAmountText = "215"

        viewModel.account = card

        #expect(viewModel.purchaseCurrencyCode == "EUR")
        #expect(!viewModel.showsChargedAmount, "the account's own currency hides the charged field again")
    }

    @Test func changingThePurchaseCurrencyClearsTheChargedAmount() async throws {
        let viewModel = try await makeViewModel()
        viewModel.account = cash
        viewModel.purchaseCurrencyCode = "EUR"
        viewModel.chargedAmountText = "215"

        viewModel.purchaseCurrencyCode = "UAH"

        #expect(viewModel.chargedAmountText.isEmpty)
        #expect(!viewModel.showsChargedAmount)
    }

    @Test func chargedAmountShowsOnlyWhenCurrencyDiffersFromTheAccount() async throws {
        let viewModel = try await makeViewModel()
        viewModel.account = cash

        #expect(!viewModel.showsChargedAmount)

        viewModel.purchaseCurrencyCode = "EUR"
        #expect(viewModel.showsChargedAmount)

        viewModel.purchaseCurrencyCode = "UAH"
        #expect(!viewModel.showsChargedAmount)
    }

    @Test func incomeNeverShowsChargedAmount() async throws {
        let viewModel = try await makeViewModel()
        viewModel.type = .income
        viewModel.account = cash

        #expect(!viewModel.showsChargedAmount)
    }

    @Test func requiresChargedAmountWhenShown() async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel, amount: "5")
        viewModel.purchaseCurrencyCode = "EUR"

        #expect(await viewModel.submit() == false)
        #expect(viewModel.chargedAmountIssue == .required)
        #expect(repository.created.isEmpty)
    }

    @Test func rejectsBadChargedAmounts() async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel, amount: "5")
        viewModel.purchaseCurrencyCode = "EUR"
        viewModel.chargedAmountText = "1,234"

        #expect(await viewModel.submit() == false)
        #expect(viewModel.chargedAmountIssue == .tooPrecise)
    }

    @Test func chargedAndPurchaseAmountsMustDiffer() async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel, amount: "5")
        viewModel.purchaseCurrencyCode = "EUR"
        viewModel.chargedAmountText = "5"

        #expect(await viewModel.submit() == false)
        #expect(viewModel.amountIssue == .equalsChargedAmount)
        #expect(viewModel.chargedAmountIssue == .equalsExpenseAmount)
    }

    @Test func computesTheExchangeRate() async throws {
        let viewModel = try await makeViewModel()
        viewModel.account = cash
        viewModel.purchaseCurrencyCode = "EUR"
        viewModel.amountText = "5"
        viewModel.chargedAmountText = "215"

        #expect(viewModel.exchangeRate == 43)
        // The digit formatting itself follows the interface language (`GEN-10`); only the currencies are checked here.
        #expect(viewModel.exchangeRateHint?.contains("EUR") == true)
        #expect(viewModel.exchangeRateHint?.contains("UAH") == true)
    }

    @Test func createsAForeignCurrencyExpense() async throws {
        let viewModel = try await makeViewModel()
        fill(viewModel, amount: "5")
        viewModel.purchaseCurrencyCode = "EUR"
        viewModel.chargedAmountText = "215"

        #expect(await viewModel.submit())

        let created = try #require(repository.created.first)
        #expect(created.transactionAmount == 5)
        #expect(created.transactionCurrencyID == FakeReferenceDataRepository.eur.id)
        #expect(created.chargedAmount == 215)
        #expect(preferences.expenseDefaults?.currencyCode == "EUR")
    }

    @Test func rememberedPurchaseCurrencyAppliesAfterTheAccount() async throws {
        preferences.expenseDefaults = TransactionFormDefaults(
            accountID: cash.id, groupID: FakeReferenceDataRepository.food.id,
            categoryID: FakeReferenceDataRepository.groceries.id, currencyCode: "EUR"
        )

        let viewModel = try await makeViewModel()

        #expect(viewModel.account == cash)
        #expect(viewModel.purchaseCurrencyCode == "EUR")
    }

    @Test func rememberedPurchaseCurrencyIsSkippedWhenNoLongerAnAccountCurrency() async throws {
        preferences.expenseDefaults = TransactionFormDefaults(
            accountID: cash.id, groupID: FakeReferenceDataRepository.food.id,
            categoryID: FakeReferenceDataRepository.groceries.id, currencyCode: "USD"
        )

        let viewModel = try await makeViewModel()

        #expect(viewModel.purchaseCurrencyCode == "UAH")
    }

    // MARK: Editing (TX-40, TX-42)

    private var editedForeignExpense: Transaction {
        Transaction(
            id: 42,
            type: .expense,
            transactedAt: Date(timeIntervalSince1970: 1_790_000_000),
            localOffset: LocalOffset(seconds: 7_200),
            transactionAmount: -5,
            transactionCurrencyCode: "EUR",
            chargedAmount: -215,
            chargedCurrencyCode: "UAH",
            accountID: cash.id,
            accountName: cash.name,
            group: Transaction.Label(id: FakeReferenceDataRepository.food.id, name: "Food", color: nil),
            category: Transaction.Label(
                id: FakeReferenceDataRepository.groceries.id,
                name: FakeReferenceDataRepository.groceries.name,
                color: FakeReferenceDataRepository.groceries.color
            ),
            comment: "Lunch",
            transferID: nil
        )
    }

    @Test func editFillsTheFormFromTheTransaction() async throws {
        let viewModel = try await makeViewModel(mode: .edit(editedForeignExpense))

        #expect(viewModel.type == .expense)
        #expect(viewModel.account == cash)
        #expect(viewModel.category == FakeReferenceDataRepository.groceries)
        #expect(viewModel.amountText == "5")
        #expect(viewModel.purchaseCurrencyCode == "EUR")
        #expect(viewModel.chargedAmountText == "215")
        #expect(viewModel.showsChargedAmount)
        #expect(viewModel.comment == "Lunch")
        #expect(viewModel.transactedAt == editedForeignExpense.transactedAt)
        #expect(viewModel.timeZone.secondsFromGMT() == 7_200)
    }

    @Test func editFillsAPlainExpenseWithoutChargedAmount() async throws {
        let transaction = Transaction.fixture(id: 5, amount: -250, currencyCode: "UAH")
        let viewModel = try await makeViewModel(mode: .edit(transaction))

        #expect(viewModel.amountText == "250")
        #expect(viewModel.chargedAmountText.isEmpty)
        #expect(!viewModel.showsChargedAmount)
    }

    @Test func editFillsAnIncome() async throws {
        let transaction = Transaction.fixture(id: 6, type: .income, amount: 3200, currencyCode: "UAH")
        let viewModel = try await makeViewModel(mode: .edit(transaction))

        #expect(viewModel.type == .income)
        #expect(viewModel.amountText == "3200")
        #expect(viewModel.purchaseCurrencyCode == "UAH")
        #expect(!viewModel.showsChargedAmount, "an income never picks a purchase currency (TX-30)")
    }

    @Test func editSavesAnUpdate() async throws {
        var savedCalls = 0
        repository.setDetails(editedForeignExpense)
        let viewModel = try await makeViewModel(mode: .edit(editedForeignExpense)) { savedCalls += 1 }
        viewModel.comment = "Dinner"

        #expect(await viewModel.submit())

        let call = try #require(repository.updated.first)
        #expect(call.id == 42)
        #expect(call.update.localOffset == LocalOffset(seconds: 7_200))
        #expect(call.update.accountID == cash.id)
        #expect(call.update.categoryID == FakeReferenceDataRepository.groceries.id)
        #expect(call.update.transactionAmount == 5)
        #expect(call.update.transactionCurrencyID == FakeReferenceDataRepository.eur.id)
        #expect(call.update.chargedAmount == 215)
        #expect(call.update.comment == "Dinner")
        #expect(savedCalls == 1)
        #expect(preferences.expenseDefaults == nil, "editing must not update TX-16's remembered choices")
    }

    @Test func editKeepsTheOriginalOffsetEvenIfTheDateChanges() async throws {
        repository.setDetails(editedForeignExpense)
        let viewModel = try await makeViewModel(mode: .edit(editedForeignExpense))
        viewModel.transactedAt = now

        #expect(await viewModel.submit())

        #expect(repository.updated.first?.update.localOffset == LocalOffset(seconds: 7_200))
    }

    @Test func editNotFoundWhenTheTransactionIsGone() async throws {
        var savedCalls = 0
        // Nothing registered under id 42 in `repository`, so `update` answers "not found".
        let viewModel = try await makeViewModel(mode: .edit(editedForeignExpense)) { savedCalls += 1 }

        #expect(await viewModel.submit() == false)

        #expect(viewModel.isNotFound)
        #expect(viewModel.failure == nil)
        #expect(savedCalls == 0)
    }

    @Test func editFailureSetsFailureNotNotFound() async throws {
        repository.setUpdateFails(true)
        let viewModel = try await makeViewModel(mode: .edit(editedForeignExpense))

        #expect(await viewModel.submit() == false)

        #expect(viewModel.failure == "duplicate key value")
        #expect(!viewModel.isNotFound)
    }

    @Test func editFailureKeepsTheFormData() async throws {
        repository.setUpdateFails(true)
        let viewModel = try await makeViewModel(mode: .edit(editedForeignExpense))
        viewModel.comment = "Dinner"

        #expect(await viewModel.submit() == false)

        #expect(viewModel.amountText == "5")
        #expect(viewModel.chargedAmountText == "215")
        #expect(viewModel.comment == "Dinner")
        #expect(viewModel.account == cash)
        #expect(viewModel.category == FakeReferenceDataRepository.groceries)
    }
}

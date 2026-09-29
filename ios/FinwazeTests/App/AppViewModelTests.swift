import Foundation
import Testing
@testable import Finwaze

@MainActor
struct AppViewModelTests {
    private let cash = Account(id: 1, name: "Cash", currencyCode: "UAH")
    private let card = Account(id: 2, name: "Card", currencyCode: "EUR")
    private let defaults = makeTestDefaults()

    private func makeViewModel(
        repository: FakeReferenceDataRepository,
        auth: FakeAuthRepository = FakeAuthRepository()
    ) -> AppViewModel {
        AppViewModel(
            authRepository: auth,
            liveRepositories: Repositories(
                accounts: repository,
                categories: repository,
                currencies: repository,
                wallet: FakeWalletRepository(),
                transactions: FakeTransactionsRepository(),
                transfers: FakeTransfersRepository(),
                groups: FakeGroupsRepository(),
                dashboard: FakeDashboardRepository(),
                budget: FakeBudgetRepository(),
                goals: FakeGoalsRepository(),
                analytics: FakeAnalyticsRepository()
            ),
            preferences: DevicePreferences(defaults: defaults),
            demoMode: DemoModeStorage(defaults: defaults)
        )
    }

    private func user(_ id: UUID = UUID()) -> UserSession {
        UserSession(userID: id, email: "user@mail.com")
    }

    @Test func startsOnSplash() {
        #expect(makeViewModel(repository: FakeReferenceDataRepository()).route == .launching)
    }

    @Test func showsAuthFlowWhenSignedOut() async {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository())

        await viewModel.apply(nil)

        #expect(viewModel.route == .signedOut)
        #expect(viewModel.user == nil)
    }

    @Test func userWithAccountsGoesToMainApp() async {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash, card]))

        await viewModel.apply(user())

        #expect(viewModel.route == .main)
        #expect(viewModel.referenceData.accounts == [cash, card])
        #expect(viewModel.referenceData.groups.count == 1)
        #expect(viewModel.preferences.primaryCurrencyCode == "UAH")
    }

    @Test func userWithoutAccountsGoesToOnboarding() async {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository())

        await viewModel.apply(user())

        #expect(viewModel.route == .onboarding)
        #expect(viewModel.preferences.primaryCurrencyCode == nil)
    }

    @Test func loadFailureCanBeRetried() async {
        let repository = FakeReferenceDataRepository(accounts: [cash], fails: true)
        let viewModel = makeViewModel(repository: repository)

        await viewModel.apply(user())
        #expect(viewModel.route == .failed)

        repository.setFails(false)
        await viewModel.retry()
        #expect(viewModel.route == .main)
    }

    @Test func keepsPrimaryCurrencyOfTheSameUser() async {
        let id = UUID()
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash, card]))
        await viewModel.apply(user(id))
        viewModel.preferences.primaryCurrencyCode = "EUR"

        await viewModel.apply(nil)
        await viewModel.apply(user(id))

        #expect(viewModel.preferences.primaryCurrencyCode == "EUR")
    }

    @Test func anotherUserDoesNotSeePreviousSettings() async {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash, card]))
        await viewModel.apply(user())
        viewModel.preferences.primaryCurrencyCode = "EUR"
        viewModel.preferences.expenseDefaults = TransactionFormDefaults(accountID: 2)

        await viewModel.apply(user())

        #expect(viewModel.preferences.primaryCurrencyCode == "UAH")
        #expect(viewModel.preferences.expenseDefaults == nil)
    }

    @Test func signOutClearsSettings() async {
        let auth = FakeAuthRepository()
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash]), auth: auth)
        await viewModel.apply(user())

        await viewModel.signOut()

        #expect(auth.calls.signOut == 1)
        #expect(viewModel.preferences.primaryCurrencyCode == nil)
    }

    @Test func signingOutResetsReferenceData() async {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash]))
        await viewModel.apply(user())

        await viewModel.apply(nil)

        #expect(viewModel.referenceData.accounts.isEmpty)
        #expect(viewModel.route == .signedOut)
    }

    // MARK: Changes to reference data (GEN-26, ONB-04)

    @Test func firstAccountOpensMainAppInItsCurrency() async throws {
        let repository = FakeReferenceDataRepository()
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())
        #expect(viewModel.route == .onboarding)

        let account = try await repository.createAccount(name: "Card", currencyID: FakeReferenceDataRepository.eur.id)
        await viewModel.accountCreated(account)

        #expect(viewModel.route == .main)
        #expect(viewModel.referenceData.accounts == [account])
        #expect(viewModel.preferences.primaryCurrencyCode == "EUR")
    }

    @Test func createdAccountCountsEvenIfReloadFails() async throws {
        let repository = FakeReferenceDataRepository()
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())

        let account = try await repository.createAccount(name: "Cash", currencyID: FakeReferenceDataRepository.uah.id)
        repository.setFails(true)
        await viewModel.accountCreated(account)

        #expect(viewModel.route == .main)
        #expect(viewModel.referenceData.accounts == [account])
    }

    @Test func reloadKeepsPrimaryCurrencyAndAddsAccount() async {
        let repository = FakeReferenceDataRepository(accounts: [cash])
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())

        repository.setAccounts([cash, card])
        await viewModel.reloadReferenceData()

        #expect(viewModel.route == .main)
        #expect(viewModel.referenceData.accounts == [cash, card])
        #expect(viewModel.preferences.primaryCurrencyCode == "UAH")
    }

    @Test func failedReloadKeepsPreviousData() async {
        let repository = FakeReferenceDataRepository(accounts: [cash])
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())

        repository.setFails(true)
        await viewModel.reloadReferenceData()

        #expect(viewModel.route == .main)
        #expect(viewModel.referenceData.accounts == [cash])
    }

    @Test func demoAccountCreationChangesNothing() async throws {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository())
        try await viewModel.enterDemo()
        await viewModel.apply(user())

        let account = try await viewModel.repositories.accounts.createAccount(name: "Card", currencyID: 3)
        await viewModel.accountCreated(account)

        #expect(account.id == DemoData.createdRowID)
        #expect(viewModel.referenceData.accounts == DemoData.accounts)
    }

    @Test func dataChangeSignalsChangedData() async {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash]))
        await viewModel.apply(user())
        let version = viewModel.dataVersion

        viewModel.dataChanged()

        #expect(viewModel.dataVersion == version + 1)
    }

    @Test func createdAccountSignalsChangedData() async throws {
        let repository = FakeReferenceDataRepository(accounts: [cash])
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())
        let version = viewModel.dataVersion

        let account = try await repository.createAccount(name: "Card", currencyID: FakeReferenceDataRepository.eur.id)
        await viewModel.accountCreated(account)

        #expect(viewModel.dataVersion == version + 1)
    }

    // MARK: Groups and categories from the picker (TX-12)

    @Test func createdGroupAndCategoryAreSelectableRightAway() async throws {
        let repository = FakeReferenceDataRepository(accounts: [cash], groups: [], categories: [])
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())

        let group = try await viewModel.createGroup(name: "Travel", type: .expense, color: "#38BDF8")
        let category = try await viewModel.createCategory(name: "Hotels", groupID: group.id, color: nil)

        #expect(viewModel.referenceData.groups == [group])
        #expect(viewModel.referenceData.categories == [category])
        #expect(group.transactionType == .expense)
        #expect(group.color == "#38BDF8")
        #expect(category.groupID == group.id)
        #expect(category.color == nil)
    }

    @Test func createdGroupStaysEvenIfReloadFails() async throws {
        let repository = FakeReferenceDataRepository(accounts: [cash], groups: [], categories: [])
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())
        repository.setFails(true)

        let group = try await viewModel.createGroup(name: "Travel", type: .income, color: nil)

        #expect(viewModel.referenceData.groups == [group])
    }

    @Test func failedGroupCreationThrows() async {
        let repository = FakeReferenceDataRepository(accounts: [cash])
        let viewModel = makeViewModel(repository: repository)
        await viewModel.apply(user())
        repository.setCreateFails(true)

        await #expect(throws: FakeCreateError.self) { try await viewModel.createGroup(name: "Travel", type: .expense, color: nil) }
        #expect(viewModel.referenceData.groups == [FakeReferenceDataRepository.food])
    }

    @Test func demoCreatesNoGroupOrCategory() async throws {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository())
        try await viewModel.enterDemo()
        await viewModel.apply(user())

        let group = try await viewModel.createGroup(name: "Travel", type: .expense, color: "#22C55E")
        _ = try await viewModel.createCategory(name: "Hotels", groupID: group.id, color: nil)

        #expect(group.id == DemoData.createdRowID)
        #expect(viewModel.referenceData.groups == DemoData.groups)
        #expect(viewModel.referenceData.categories == DemoData.categories)
    }

    // MARK: Demo mode (AUTH-10)

    @Test func demoSignsInToServerDemoAccount() async throws {
        let auth = FakeAuthRepository()
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(), auth: auth)

        try await viewModel.enterDemo()

        #expect(auth.calls.signInWithDemo == 1)
        #expect(viewModel.isDemo)
    }

    @Test func demoSessionUsesLocalDemoData() async throws {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(fails: true))
        try await viewModel.enterDemo()

        await viewModel.apply(user())

        #expect(viewModel.route == .main)
        #expect(viewModel.referenceData.accounts == DemoData.accounts)
        #expect(viewModel.preferences.primaryCurrencyCode == "USD")
    }

    @Test func failedDemoSignInLeavesDemoOff() async {
        let viewModel = makeViewModel(
            repository: FakeReferenceDataRepository(),
            auth: FakeAuthRepository(signInFailure: .network)
        )

        await #expect(throws: AuthFailure.network) { try await viewModel.enterDemo() }

        #expect(!viewModel.isDemo)
        #expect(!makeViewModel(repository: FakeReferenceDataRepository()).isDemo)
    }

    @Test func relaunchWithDemoSessionStaysInDemo() async throws {
        try await makeViewModel(repository: FakeReferenceDataRepository()).enterDemo()
        let relaunched = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash]))

        await relaunched.apply(user())

        #expect(relaunched.isDemo)
        #expect(relaunched.referenceData.accounts == DemoData.accounts)
    }

    @Test func endedSessionTurnsDemoOff() async throws {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository())
        try await viewModel.enterDemo()
        await viewModel.apply(user())

        await viewModel.apply(nil)

        #expect(!viewModel.isDemo)
        #expect(viewModel.route == .signedOut)
    }

    @Test func signOutLeavesDemo() async throws {
        let auth = FakeAuthRepository()
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(), auth: auth)
        try await viewModel.enterDemo()
        await viewModel.apply(user())

        await viewModel.signOut()

        #expect(!viewModel.isDemo)
        #expect(auth.calls.signOut == 1)
        #expect(viewModel.preferences.primaryCurrencyCode == nil)
    }

    @Test func demoAndLiveUseDifferentRepositories() async throws {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash]))
        #expect(try await viewModel.repositories.accounts.regularAccounts() == [cash])

        try await viewModel.enterDemo()

        #expect(try await viewModel.repositories.accounts.regularAccounts() == DemoData.accounts)
    }
}

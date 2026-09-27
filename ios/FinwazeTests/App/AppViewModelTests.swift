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
            liveRepositories: Repositories(accounts: repository, categories: repository, currencies: repository),
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

    // MARK: Demo mode (AUTH-10)

    @Test func demoOpensMainAppWithDemoData() async {
        let auth = FakeAuthRepository()
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(fails: true), auth: auth)

        await viewModel.enterDemo()

        #expect(viewModel.isDemo)
        #expect(viewModel.route == .main)
        #expect(viewModel.referenceData.accounts == DemoData.accounts)
        #expect(viewModel.preferences.primaryCurrencyCode == "USD")
        #expect(viewModel.user?.email == nil)
        #expect(auth.calls.signIn.isEmpty)
    }

    @Test func relaunchStaysInDemoDespiteMissingSession() async {
        await makeViewModel(repository: FakeReferenceDataRepository()).enterDemo()
        let relaunched = makeViewModel(
            repository: FakeReferenceDataRepository(),
            auth: FakeAuthRepository(sessionEvents: [nil])
        )

        await relaunched.observeSession()

        #expect(relaunched.isDemo)
        #expect(relaunched.route == .main)
        #expect(relaunched.referenceData.accounts == DemoData.accounts)
    }

    @Test func leavingDemoSkipsServerAndDisablesIt() async {
        let auth = FakeAuthRepository()
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(), auth: auth)
        await viewModel.enterDemo()

        await viewModel.signOut()

        #expect(!viewModel.isDemo)
        #expect(viewModel.route == .signedOut)
        #expect(viewModel.referenceData.accounts.isEmpty)
        #expect(viewModel.preferences.primaryCurrencyCode == nil)
        #expect(auth.calls.signOut == 0)
        #expect(!makeViewModel(repository: FakeReferenceDataRepository()).isDemo)
    }

    @Test func demoAndLiveUseDifferentRepositories() async throws {
        let viewModel = makeViewModel(repository: FakeReferenceDataRepository(accounts: [cash]))
        #expect(try await viewModel.repositories.accounts.regularAccounts() == [cash])

        await viewModel.enterDemo()

        #expect(try await viewModel.repositories.accounts.regularAccounts() == DemoData.accounts)
    }
}

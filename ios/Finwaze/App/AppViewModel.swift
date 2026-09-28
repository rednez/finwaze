import Foundation
import Observation

/// App-wide state: follows the session and decides which part of the app is shown (`NAV-06…09`).
/// Also owns demo mode (`AUTH-10`): a session in the shared server demo account, but local demo data
/// and writes that change nothing.
@Observable
final class AppViewModel {
    enum Route: Equatable {
        /// Restoring the session or loading reference data — a neutral splash (`NAV-09`).
        case launching
        case signedOut
        /// Signed in without a regular account (`NAV-07`).
        case onboarding
        case main
        /// Reference data failed to load (`GEN-25`).
        case failed
    }

    private(set) var route: Route = .launching
    private(set) var user: UserSession?
    private(set) var isDemo: Bool
    /// Grows with every change to the user's data; screens reload on it so they show current figures (`GEN-26`).
    private(set) var dataVersion = 0

    let referenceData: ReferenceDataStore
    let preferences: DevicePreferences
    private let authRepository: any AuthRepository
    private let liveRepositories: Repositories
    private let demoRepositories: Repositories
    @ObservationIgnored private let demoMode: DemoModeStorage
    @ObservationIgnored private var sessionTask: Task<Void, Never>?

    init(
        authRepository: any AuthRepository,
        liveRepositories: Repositories,
        demoRepositories: Repositories = .demo,
        referenceData: ReferenceDataStore = ReferenceDataStore(),
        preferences: DevicePreferences,
        demoMode: DemoModeStorage
    ) {
        self.authRepository = authRepository
        self.liveRepositories = liveRepositories
        self.demoRepositories = demoRepositories
        self.referenceData = referenceData
        self.preferences = preferences
        self.demoMode = demoMode
        isDemo = demoMode.isEnabled
    }

    /// The repositories for the current mode; features take theirs from here.
    var repositories: Repositories {
        isDemo ? demoRepositories : liveRepositories
    }

    /// Follows session changes for as long as the calling task lives.
    func observeSession() async {
        for await user in authRepository.sessionChanges() {
            // Token refreshes re-emit the same user; the app is already set up (or being set up) for them.
            if let user, user.userID == self.user?.userID {
                self.user = user
                continue
            }
            // A different user or a sign-out supersedes a load still running for the previous session.
            self.user = user
            sessionTask?.cancel()
            sessionTask = Task { await apply(user) }
        }
        sessionTask?.cancel()
    }

    /// Sets the app up for `user`, or shows the auth flow when `nil`.
    func apply(_ user: UserSession?) async {
        self.user = user
        guard let user else {
            // Demo mode lives only as long as its session.
            setDemo(false)
            referenceData.reset()
            route = .signedOut
            return
        }
        preferences.prepare(for: user.userID)
        await loadReferenceData()
    }

    /// "Try demo mode": signs in to the server demo account; the session then opens the app with local
    /// demo data (`AUTH-10`, `Q-08`).
    func enterDemo() async throws(AuthFailure) {
        // Set before signing in, so the session event that follows is already handled as demo.
        setDemo(true)
        do {
            try await authRepository.signInWithDemo()
        } catch {
            setDemo(false)
            throw error
        }
    }

    func retry() async {
        await loadReferenceData()
    }

    /// Ends the session or leaves demo mode, clearing this device's settings (`AUTH-11`).
    func signOut() async {
        preferences.clear()
        setDemo(false)
        // A failed server-side sign-out still clears the local session, so there is nothing to report.
        try? await authRepository.signOut()
    }

    private func setDemo(_ isDemo: Bool) {
        demoMode.isEnabled = isDemo
        self.isDemo = isDemo
    }

    private func loadReferenceData() async {
        route = .launching
        do {
            try await referenceData.load(using: repositories)
        } catch {
            guard !Task.isCancelled else { return }
            route = .failed
            return
        }
        guard !Task.isCancelled else { return }
        applyReferenceData()
    }

    /// Reloads reference data after a change, so every screen sees it (`GEN-26`), then re-derives the route and
    /// the primary currency (`NAV-11`). Unlike the first load it keeps the current screen; on failure the
    /// previous data stays.
    func reloadReferenceData() async {
        do {
            try await referenceData.load(using: repositories)
        } catch {
            return
        }
        applyReferenceData()
    }

    /// A new account was created: it is usable right away, even if the reload that follows fails — the first one
    /// moves onboarding to the main app (`ONB-04`) and must not be offered for creation again.
    /// In demo mode nothing was stored, so the data is only reloaded and stays as it was (`AUTH-10`).
    func accountCreated(_ account: Account) async {
        if !isDemo {
            referenceData.add(account)
            applyReferenceData()
        }
        await reloadReferenceData()
        dataChanged()
    }

    /// An account was renamed, changed currency or got a new balance (`ACC-09`, `ACC-10`): forms, filters and
    /// balances follow (`GEN-26`), and the primary currency is re-derived if its last account moved on (`NAV-11`).
    func accountUpdated() async {
        await reloadReferenceData()
        dataChanged()
    }

    /// An account was deleted (`ACC-11`): it disappears everywhere; deleting the last one leads to onboarding
    /// (`NAV-07`).
    func accountDeleted() async {
        await reloadReferenceData()
        dataChanged()
    }

    /// A transaction was created: balances and lists follow (`GEN-26`).
    func transactionCreated() {
        dataChanged()
    }

    /// A transaction was edited (`TX-40`): balances and lists follow (`GEN-26`).
    func transactionUpdated() {
        dataChanged()
    }

    /// A transaction was deleted (`TX-41`): balances and lists follow (`GEN-26`).
    func transactionDeleted() {
        dataChanged()
    }

    /// A transfer was made (`TRF-05`): both balances and the lists follow (`GEN-26`).
    func transferMade() {
        dataChanged()
    }

    /// A transfer was deleted (`TRF-08`): both balances and the lists follow (`GEN-26`).
    func transferDeleted() {
        dataChanged()
    }

    /// A month's budget plan was saved (`BUD-26`): the Budget and the Dashboard's budget card follow (`GEN-26`).
    func budgetSaved() {
        dataChanged()
    }

    /// A goal was created, edited, completed, cancelled or deleted, or money went in or out of it (`GOAL-13…25`):
    /// Goals, the Dashboard's goals and balance, the Wallet's balances and the transactions list follow (`GEN-26`).
    func goalsChanged() {
        dataChanged()
    }

    /// A group or category was renamed, recoloured or deleted (`CAT-05…10`): the category picker, the transaction
    /// filters and the transactions list follow (`GEN-26`).
    func categoriesChanged() async {
        await reloadReferenceData()
        dataChanged()
    }

    /// Creates a group from the category picker (`TX-12`). It is selectable right away, even if the reload that
    /// follows fails; in demo mode nothing is stored, so it does not appear (`AUTH-10`).
    func createGroup(name: String, type: TransactionType, color: String?) async throws -> CategoryGroup {
        let group = try await repositories.categories.createGroup(name: name, type: type, color: color)
        if !isDemo {
            referenceData.add(group)
        }
        await reloadReferenceData()
        dataChanged()
        return group
    }

    /// Creates a category in `groupID` from the category picker (`TX-12`); see `createGroup(name:type:color:)`.
    func createCategory(name: String, groupID: Int64, color: String?) async throws -> Category {
        let category = try await repositories.categories.createCategory(name: name, groupID: groupID, color: color)
        if !isDemo {
            referenceData.add(category)
        }
        await reloadReferenceData()
        dataChanged()
        return category
    }

    private func dataChanged() {
        dataVersion += 1
    }

    private func applyReferenceData() {
        preferences.primaryCurrencyCode = PrimaryCurrencyResolver.resolve(
            stored: preferences.primaryCurrencyCode,
            accounts: referenceData.accounts
        )
        route = referenceData.accounts.isEmpty ? .onboarding : .main
    }
}

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

    /// Accounts, groups or categories changed — renamed, recoloured, re-currencied, rebalanced or deleted
    /// (`ACC-09…11`, `CAT-05…10`): forms, filters and balances follow (`GEN-26`), the primary currency is re-derived
    /// if its last account moved on (`NAV-11`), and deleting the last account leads to onboarding (`NAV-07`).
    func referenceDataChanged() async {
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

    /// A transaction, transfer, budget plan or goal was saved or deleted (`TX-40`, `TX-41`, `TRF-05`, `TRF-08`,
    /// `BUD-26`, `GOAL-13…25`): balances and lists follow (`GEN-26`).
    func dataChanged() {
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

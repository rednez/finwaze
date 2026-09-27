import Foundation
import Observation

/// App-wide state: follows the session and decides which part of the app is shown (`NAV-06…09`).
/// Also owns demo mode (`AUTH-10`): no Supabase session, local demo data, writes that change nothing.
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
        if isDemo {
            await startDemo()
        }
        for await user in authRepository.sessionChanges() {
            // Demo mode has no Supabase session; auth events don't apply to it.
            guard !isDemo else { continue }
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
            referenceData.reset()
            route = .signedOut
            return
        }
        preferences.prepare(for: user.userID)
        await loadReferenceData()
    }

    /// "Try demo mode": opens the app with local demo data, without an account or network (`AUTH-10`).
    func enterDemo() async {
        sessionTask?.cancel()
        demoMode.isEnabled = true
        isDemo = true
        await startDemo()
    }

    func retry() async {
        await loadReferenceData()
    }

    /// Ends the session or leaves demo mode, clearing this device's settings (`AUTH-11`).
    func signOut() async {
        preferences.clear()
        guard !isDemo else {
            demoMode.isEnabled = false
            isDemo = false
            await apply(nil)
            return
        }
        // A failed server-side sign-out still clears the local session, so there is nothing to report.
        try? await authRepository.signOut()
    }

    private func startDemo() async {
        user = UserSession(userID: DemoData.userID, email: nil)
        preferences.prepare(for: DemoData.userID)
        await loadReferenceData()
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

        preferences.primaryCurrencyCode = PrimaryCurrencyResolver.resolve(
            stored: preferences.primaryCurrencyCode,
            accounts: referenceData.accounts
        )
        route = referenceData.accounts.isEmpty ? .onboarding : .main
    }
}

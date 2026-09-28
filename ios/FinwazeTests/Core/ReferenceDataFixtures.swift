import Foundation
@testable import Finwaze

@MainActor
extension Repositories {
    /// Live-like repositories over fakes, for view models that read reference data.
    static func fake(
        referenceData: FakeReferenceDataRepository = FakeReferenceDataRepository(),
        transactions: FakeTransactionsRepository = FakeTransactionsRepository(),
        transfers: FakeTransfersRepository = FakeTransfersRepository(),
        groups: FakeGroupsRepository = FakeGroupsRepository(),
        dashboard: FakeDashboardRepository = FakeDashboardRepository(),
        budget: FakeBudgetRepository = FakeBudgetRepository(),
        goals: FakeGoalsRepository = FakeGoalsRepository(),
        analytics: FakeAnalyticsRepository = FakeAnalyticsRepository()
    ) -> Repositories {
        Repositories(
            accounts: referenceData,
            categories: referenceData,
            currencies: referenceData,
            wallet: FakeWalletRepository(),
            transactions: transactions,
            transfers: transfers,
            groups: groups,
            dashboard: dashboard,
            budget: budget,
            goals: goals,
            analytics: analytics
        )
    }
}

/// A reference data store loaded from `repository`.
@MainActor
func makeReferenceData(_ repository: FakeReferenceDataRepository) async throws -> ReferenceDataStore {
    let store = ReferenceDataStore()
    try await store.load(using: .fake(referenceData: repository))
    return store
}

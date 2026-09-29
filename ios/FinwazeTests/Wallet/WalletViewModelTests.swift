import Foundation
import Testing
@testable import Finwaze

@MainActor
struct WalletViewModelTests {
    private let cash = WalletAccount(id: 1, name: "Cash", currencyCode: "UAH", balance: 18500)
    private let card = WalletAccount(id: 2, name: "Card", currencyCode: "EUR", balance: 0)

    @Test func startsLoading() {
        #expect(WalletViewModel(repository: FakeWalletRepository()).state == .loading)
    }

    @Test func showsAccounts() async {
        let viewModel = WalletViewModel(repository: FakeWalletRepository(accounts: [cash]))

        await viewModel.refresh()

        #expect(viewModel.state == .loaded([cash]))
    }

    @Test func emptyWalletIsLoadedWithoutAccounts() async {
        let viewModel = WalletViewModel(repository: FakeWalletRepository())

        await viewModel.refresh()

        #expect(viewModel.state == .loaded([]))
    }

    @Test func failureCanBeRetried() async {
        let repository = FakeWalletRepository(accounts: [cash], fails: true)
        let viewModel = WalletViewModel(repository: repository)

        await viewModel.refresh()
        #expect(viewModel.state == .failed)

        repository.setFails(false)
        await viewModel.refresh()
        #expect(viewModel.state == .loaded([cash]))
    }

    @Test func reloadShowsNewAccount() async {
        let repository = FakeWalletRepository(accounts: [cash])
        let viewModel = WalletViewModel(repository: repository)
        await viewModel.refresh()

        repository.setAccounts([card, cash])
        await viewModel.refresh()

        #expect(viewModel.state == .loaded([card, cash]))
    }

    @Test func demoWalletIsSortedByName() async {
        let viewModel = WalletViewModel(repository: DemoWalletRepository())

        await viewModel.refresh()

        guard case .loaded(let accounts) = viewModel.state else {
            Issue.record("Expected loaded accounts")
            return
        }
        #expect(accounts.map(\.name) == ["Cash", "Main Card", "Savings"])
    }
}

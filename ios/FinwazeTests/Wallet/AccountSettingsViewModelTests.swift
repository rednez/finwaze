import Foundation
import Testing
@testable import Finwaze

@MainActor
struct AccountSettingsViewModelTests {
    private let now = Date(timeIntervalSince1970: 1_790_500_500)
    private let repository = FakeWalletRepository()

    private func details(balance: Decimal = 1000, canDelete: Bool = true) -> AccountDetails {
        AccountDetails(id: 5, name: "Cash", currencyID: 1, currencyCode: "UAH", balance: balance, canDelete: canDelete)
    }

    private func makeViewModel(
        locale: Locale = Locale(identifier: "en_US"),
        onChanged: @escaping () async -> Void = {},
        onDeleted: @escaping () async -> Void = {}
    ) async throws -> AccountSettingsViewModel {
        let referenceData = try await makeReferenceData(FakeReferenceDataRepository())
        let now = now
        return AccountSettingsViewModel(
            accountID: 5,
            referenceData: referenceData,
            repository: repository,
            clock: { now },
            locale: locale,
            onChanged: onChanged,
            onDeleted: onDeleted
        )
    }

    private func loaded(_ details: AccountDetails? = nil, onChanged: @escaping () async -> Void = {}, onDeleted: @escaping () async -> Void = {}) async throws -> AccountSettingsViewModel {
        repository.setDetails(details ?? self.details())
        let viewModel = try await makeViewModel(onChanged: onChanged, onDeleted: onDeleted)
        await viewModel.load()
        return viewModel
    }

    // MARK: Load

    @Test func startsLoading() async throws {
        #expect(try await makeViewModel().state == .loading)
    }

    @Test func fillsTheFormFromTheAccount() async throws {
        let viewModel = try await loaded()

        #expect(viewModel.state == .loaded(details()))
        #expect(viewModel.name == "Cash")
        #expect(viewModel.currency == FakeReferenceDataRepository.uah)
        #expect(viewModel.balanceText == "1000")
        #expect(!viewModel.usesBalanceDate)
        #expect(viewModel.isCurrencyEditable)
        #expect(viewModel.canDelete)
    }

    @Test(arguments: [("en_US", "4101.1", "4101.10"), ("uk_UA", "4101.1", "4101,10"), ("uk_UA", "-300", "-300"), ("uk_UA", "12500", "12500")])
    func showsTheBalanceInTheInterfaceLanguage(locale: String, balance: String, expected: String) async throws {
        repository.setDetails(details(balance: Decimal(string: balance)!))
        let viewModel = try await makeViewModel(locale: Locale(identifier: locale))

        await viewModel.load()

        #expect(viewModel.balanceText == expected)
    }

    /// Loading "4101,10" and saving it untouched must not add a correction for a formatting difference.
    @Test func reformattedBalanceCountsAsUnchanged() async throws {
        repository.setDetails(details(balance: Decimal(string: "4101.1")!))
        let viewModel = try await makeViewModel(locale: Locale(identifier: "uk_UA"))
        await viewModel.load()

        #expect(await viewModel.submit())

        #expect(repository.adjustments.isEmpty)
    }

    @Test func accountWithTransactionsLocksCurrencyAndDeletion() async throws {
        let viewModel = try await loaded(details(canDelete: false))

        #expect(!viewModel.isCurrencyEditable)
        #expect(!viewModel.canDelete)
    }

    @Test func notFoundWhenTheAccountIsGone() async throws {
        let viewModel = try await makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .notFound)
    }

    @Test func failedWhenLoadingErrors() async throws {
        repository.setFails(true)
        let viewModel = try await makeViewModel()

        await viewModel.load()

        #expect(viewModel.state == .failed)
    }

    // MARK: Validation

    @Test func hidesErrorsUntilSubmit() async throws {
        let viewModel = try await loaded()
        viewModel.name = "ab"
        viewModel.balanceText = ""

        #expect(viewModel.nameIssue == nil)
        #expect(viewModel.balanceIssue == nil)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.nameIssue == .length)
        #expect(viewModel.balanceIssue == .required)
        #expect(repository.updated.isEmpty)
    }

    @Test(arguments: [("abc", SignedAmountInput.Issue.invalid), ("-", .invalid), ("1.005", .tooPrecise)])
    func rejectsInvalidBalances(text: String, issue: SignedAmountInput.Issue) async throws {
        let viewModel = try await loaded()
        viewModel.balanceText = text

        #expect(await viewModel.submit() == false)

        #expect(viewModel.balanceIssue == issue)
    }

    @Test func rejectsADateInTheFuture() async throws {
        let viewModel = try await loaded()
        viewModel.usesBalanceDate = true
        viewModel.balanceDate = now.addingTimeInterval(3600)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.dateIssue == .inFuture)
        #expect(repository.updated.isEmpty)
    }

    // MARK: Submit

    @Test func unchangedBalanceAddsNoCorrection() async throws {
        var changes = 0
        let viewModel = try await loaded(onChanged: { changes += 1 })
        viewModel.name = "  Wallet cash "

        #expect(await viewModel.submit())

        #expect(repository.updated == [.init(id: 5, update: AccountUpdate(name: "Wallet cash", currencyID: nil))])
        #expect(repository.adjustments.isEmpty)
        #expect(changes == 1)
    }

    @Test func changedBalanceIsSetAsOfNow() async throws {
        let viewModel = try await loaded()
        viewModel.balanceText = "-250,5"

        #expect(await viewModel.submit())

        #expect(
            repository.adjustments == [
                BalanceAdjustment(
                    accountID: 5, targetBalance: Decimal(string: "-250.5")!, balanceDate: now,
                    localOffset: LocalOffset.current(at: now)
                )
            ]
        )
    }

    @Test func changedBalanceIsSetAsOfTheChosenDate() async throws {
        let viewModel = try await loaded()
        let earlier = now.addingTimeInterval(-86_400 * 3)
        viewModel.balanceText = "1200"
        viewModel.usesBalanceDate = true
        viewModel.balanceDate = earlier

        #expect(await viewModel.submit())

        #expect(repository.adjustments.first?.balanceDate == earlier)
        #expect(repository.adjustments.first?.localOffset == LocalOffset.current(at: earlier))
    }

    @Test func sendsTheCurrencyOnlyWhenItMayAndDidChange() async throws {
        let unlocked = try await loaded()
        unlocked.currency = FakeReferenceDataRepository.eur
        #expect(await unlocked.submit())

        let locked = try await loaded(details(canDelete: false))
        locked.currency = FakeReferenceDataRepository.eur
        #expect(await locked.submit())

        #expect(repository.updated.map(\.update.currencyID) == [2, nil])
    }

    @Test func notFoundWhenTheAccountIsDeletedBeforeSaving() async throws {
        let viewModel = try await loaded()
        repository.removeDetails(id: 5)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.state == .notFound)
    }

    @Test func updateFailureKeepsTheEnteredData() async throws {
        repository.setUpdateFails(true)
        var changes = 0
        let viewModel = try await loaded(onChanged: { changes += 1 })
        viewModel.name = "Renamed"

        #expect(await viewModel.submit() == false)

        #expect(viewModel.failure == "duplicate key value")
        #expect(viewModel.name == "Renamed")
        #expect(changes == 0)
        #expect(!viewModel.isSubmitting)
    }

    /// The name is already saved when the correction fails: the other screens are told, the form stays.
    @Test func correctionFailureStillNotifiesOfTheRename() async throws {
        repository.setAdjustFails(true)
        var changes = 0
        let viewModel = try await loaded(onChanged: { changes += 1 })
        viewModel.name = "Renamed"
        viewModel.balanceText = "5"

        #expect(await viewModel.submit() == false)

        #expect(viewModel.failure == "duplicate key value")
        #expect(changes == 1)
        #expect(viewModel.balanceText == "5")
    }

    // MARK: Delete

    @Test func deleteNotifiesOnSuccess() async throws {
        var deletions = 0
        let viewModel = try await loaded(onDeleted: { deletions += 1 })

        #expect(await viewModel.delete())

        #expect(repository.deletedIDs == [5])
        #expect(deletions == 1)
        #expect(!viewModel.isDeleting)
    }

    @Test func accountWithTransactionsCannotBeDeleted() async throws {
        let viewModel = try await loaded(details(canDelete: false))

        #expect(await viewModel.delete() == false)

        #expect(repository.deletedIDs.isEmpty)
    }

    @Test func deleteFailureKeepsTheScreen() async throws {
        repository.setDeleteFails(true)
        var deletions = 0
        let viewModel = try await loaded(onDeleted: { deletions += 1 })

        #expect(await viewModel.delete() == false)

        #expect(viewModel.deletionFailure == "duplicate key value")
        #expect(deletions == 0)
    }
}

import Foundation
import Testing
@testable import Finwaze

@MainActor
struct AccountFormViewModelTests {
    private let repository = FakeReferenceDataRepository()

    private func makeViewModel(
        name: String = "Cash",
        currency: Currency? = FakeReferenceDataRepository.uah,
        onCreated: @escaping (Account) async -> Void = { _ in }
    ) -> AccountFormViewModel {
        let viewModel = AccountFormViewModel(repository: repository, onCreated: onCreated)
        viewModel.name = name
        viewModel.currency = currency
        return viewModel
    }

    @Test func hidesErrorsUntilSubmit() {
        let viewModel = makeViewModel(name: "", currency: nil)

        #expect(viewModel.nameIssue == nil)
        #expect(viewModel.currencyIssue == nil)
    }

    @Test(arguments: [
        ("", false), ("ab", false), ("  ab  ", false), ("abc", true),
        (String(repeating: "a", count: 30), true), (String(repeating: "a", count: 31), false),
    ])
    func nameMustBeThreeToThirtyCharacters(_ name: String, isValid: Bool) async {
        let viewModel = makeViewModel(name: name)

        let created = await viewModel.submit()

        #expect(created == isValid)
        #expect((viewModel.nameIssue == nil) == isValid)
        #expect(repository.created.count == (isValid ? 1 : 0))
    }

    @Test func currencyIsRequired() async {
        let viewModel = makeViewModel(currency: nil)

        #expect(await viewModel.submit() == false)

        #expect(viewModel.currencyIssue == .required)
        #expect(repository.created.isEmpty)
    }

    @Test func createsAccountWithTrimmedName() async {
        var createdAccount: Account?
        let viewModel = makeViewModel(name: " Card ", currency: FakeReferenceDataRepository.eur) { createdAccount = $0 }

        #expect(await viewModel.submit())

        #expect(repository.created.map(\.name) == ["Card"])
        #expect(repository.created.map(\.currencyID) == [2])
        #expect(createdAccount?.currencyCode == "EUR")
        #expect(!viewModel.isSubmitting)
    }

    @Test func failureKeepsTheFormData() async {
        repository.setCreateFails(true)
        var createdAccount: Account?
        let viewModel = makeViewModel { createdAccount = $0 }

        #expect(await viewModel.submit() == false)

        #expect(viewModel.failure == "duplicate key value")
        #expect(viewModel.name == "Cash")
        #expect(viewModel.currency == FakeReferenceDataRepository.uah)
        #expect(createdAccount == nil)
        #expect(!viewModel.isSubmitting)
    }

    @Test func ignoresSubmitWhileCreating() async {
        let repository = SuspendedAccountsRepository()
        let viewModel = AccountFormViewModel(repository: repository) { _ in }
        viewModel.name = "Cash"
        viewModel.currency = FakeReferenceDataRepository.uah

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

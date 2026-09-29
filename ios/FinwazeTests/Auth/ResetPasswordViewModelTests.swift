import Testing
@testable import Finwaze

@MainActor
struct ResetPasswordViewModelTests {
    @Test func prefillsEmailFromSignIn() {
        let viewModel = ResetPasswordViewModel(repository: FakeAuthRepository(), email: "user@mail.com")

        #expect(viewModel.email == "user@mail.com")
        #expect(viewModel.emailIssue == nil)
    }

    @Test func invalidEmailDoesNotCallRepository() async {
        let repository = FakeAuthRepository()
        let viewModel = ResetPasswordViewModel(repository: repository, email: "user")

        await viewModel.sendLink()

        #expect(viewModel.emailIssue == .invalid)
        #expect(repository.calls.passwordReset.isEmpty)
        #expect(viewModel.sentEmail == nil)
    }

    @Test func sendsLinkToTrimmedEmail() async {
        let repository = FakeAuthRepository()
        let viewModel = ResetPasswordViewModel(repository: repository, email: " user@mail.com ")

        await viewModel.sendLink()

        #expect(repository.calls.passwordReset == ["user@mail.com"])
        #expect(viewModel.sentEmail == "user@mail.com")
        #expect(!viewModel.isSubmitting)
    }

    @Test func exposesRepositoryFailure() async {
        let viewModel = ResetPasswordViewModel(
            repository: FakeAuthRepository(resetFailure: .rateLimited),
            email: "user@mail.com"
        )

        await viewModel.sendLink()

        #expect(viewModel.failure == .rateLimited)
        #expect(viewModel.sentEmail == nil)
    }
}

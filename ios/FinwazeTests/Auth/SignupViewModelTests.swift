import Testing
@testable import Finwaze

@MainActor
struct SignupViewModelTests {
    private func filledViewModel(repository: FakeAuthRepository) -> SignupViewModel {
        let viewModel = SignupViewModel(repository: repository)
        viewModel.email = "new@mail.com"
        viewModel.password = "secret123"
        viewModel.confirmation = "secret123"
        return viewModel
    }

    @Test func mismatchedPasswordsDoNotCallRepository() async {
        let repository = FakeAuthRepository()
        let viewModel = filledViewModel(repository: repository)
        viewModel.confirmation = "secret124"

        await viewModel.signUp()

        #expect(viewModel.confirmationIssue == .mismatch)
        #expect(repository.calls.signUp.isEmpty)
    }

    @Test func showsConfirmationWhenEmailMustBeVerified() async {
        let repository = FakeAuthRepository(signUpResult: .success(.confirmationRequired))
        let viewModel = filledViewModel(repository: repository)

        await viewModel.signUp()

        #expect(repository.calls.signUp.map(\.email) == ["new@mail.com"])
        #expect(viewModel.confirmationEmail != nil)
    }

    @Test func staysOnFormWhenSignedInImmediately() async {
        let viewModel = filledViewModel(repository: FakeAuthRepository(signUpResult: .success(.signedIn)))

        await viewModel.signUp()

        #expect(viewModel.confirmationEmail == nil)
        #expect(viewModel.failure == nil)
    }

    @Test func exposesRepositoryFailure() async {
        let viewModel = filledViewModel(repository: FakeAuthRepository(signUpResult: .failure(.weakPassword)))

        await viewModel.signUp()

        #expect(viewModel.failure == .weakPassword)
        #expect(viewModel.confirmationEmail == nil)
    }

    @Test func doesNotRevealExistingAccount() async {
        let viewModel = filledViewModel(repository: FakeAuthRepository(signUpResult: .failure(.userAlreadyExists)))

        await viewModel.signUp()

        #expect(viewModel.failure == nil)
        #expect(viewModel.confirmationEmail == "new@mail.com")
    }

    @Test func resendsConfirmationToRegisteredEmail() async {
        let repository = FakeAuthRepository()
        let viewModel = filledViewModel(repository: repository)
        viewModel.email = " new@mail.com "
        await viewModel.signUp()

        await viewModel.resendConfirmation()

        #expect(repository.calls.resendConfirmation == ["new@mail.com"])
        #expect(viewModel.didResend)
        #expect(!viewModel.isResending)
    }

    @Test func resendDoesNothingBeforeSignUp() async {
        let repository = FakeAuthRepository()
        let viewModel = filledViewModel(repository: repository)

        await viewModel.resendConfirmation()

        #expect(repository.calls.resendConfirmation.isEmpty)
    }

    @Test func exposesResendFailure() async {
        let viewModel = filledViewModel(repository: FakeAuthRepository(resendFailure: .rateLimited))
        await viewModel.signUp()

        await viewModel.resendConfirmation()

        #expect(viewModel.resendFailure == .rateLimited)
        #expect(!viewModel.didResend)
    }
}

import Testing
@testable import Finwaze

@MainActor
struct EmailSignInViewModelTests {
    @Test func hidesValidationUntilFirstSubmit() {
        let viewModel = EmailSignInViewModel(repository: FakeAuthRepository())

        #expect(viewModel.emailIssue == nil)
        #expect(viewModel.passwordIssue == nil)
    }

    @Test func startsWithGivenEmail() {
        let viewModel = EmailSignInViewModel(repository: FakeAuthRepository(), email: "user@mail.com")

        #expect(viewModel.email == "user@mail.com")
        #expect(viewModel.password.isEmpty)
    }

    @Test func invalidFormDoesNotCallRepository() async {
        let repository = FakeAuthRepository()
        let viewModel = EmailSignInViewModel(repository: repository)
        viewModel.email = "not-an-email"

        await viewModel.signIn()

        #expect(viewModel.emailIssue == .invalid)
        #expect(viewModel.passwordIssue == .required)
        #expect(repository.calls.signIn.isEmpty)
    }

    @Test func signsInWithTrimmedEmail() async {
        let repository = FakeAuthRepository()
        let viewModel = EmailSignInViewModel(repository: repository)
        viewModel.email = " user@mail.com "
        viewModel.password = "secret"

        await viewModel.signIn()

        #expect(repository.calls.signIn.map(\.email) == ["user@mail.com"])
        #expect(repository.calls.signIn.map(\.password) == ["secret"])
        #expect(viewModel.failure == nil)
        #expect(!viewModel.isSubmitting)
    }

    @Test func exposesRepositoryFailure() async {
        let viewModel = EmailSignInViewModel(repository: FakeAuthRepository(signInFailure: .invalidCredentials))
        viewModel.email = "user@mail.com"
        viewModel.password = "wrong"

        await viewModel.signIn()

        #expect(viewModel.failure == .invalidCredentials)
    }

    @Test func tracksSubmission() async {
        let repository = SuspendedSignInRepository()
        let viewModel = EmailSignInViewModel(repository: repository)
        viewModel.email = "user@mail.com"
        viewModel.password = "secret"

        let signIn = Task { await viewModel.signIn() }
        await repository.waitUntilCalled()

        #expect(viewModel.isSubmitting)

        repository.resume()
        await signIn.value
        #expect(!viewModel.isSubmitting)
    }
}

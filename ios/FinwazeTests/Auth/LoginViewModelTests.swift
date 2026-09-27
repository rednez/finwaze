import Testing
@testable import Finwaze

@MainActor
struct LoginViewModelTests {
    @Test func hidesValidationUntilFirstSubmit() {
        let viewModel = LoginViewModel(repository: FakeAuthRepository())

        #expect(viewModel.emailIssue == nil)
        #expect(viewModel.passwordIssue == nil)
    }

    @Test func invalidFormDoesNotCallRepository() async {
        let repository = FakeAuthRepository()
        let viewModel = LoginViewModel(repository: repository)
        viewModel.email = "not-an-email"

        await viewModel.signIn()

        #expect(viewModel.emailIssue == .invalid)
        #expect(viewModel.passwordIssue == .required)
        #expect(repository.calls.signIn.isEmpty)
    }

    @Test func signsInWithTrimmedEmail() async {
        let repository = FakeAuthRepository()
        let viewModel = LoginViewModel(repository: repository)
        viewModel.email = " user@mail.com "
        viewModel.password = "secret"

        await viewModel.signIn()

        #expect(repository.calls.signIn.map(\.email) == ["user@mail.com"])
        #expect(repository.calls.signIn.map(\.password) == ["secret"])
        #expect(viewModel.failure == nil)
        #expect(viewModel.pendingMethod == nil)
    }

    @Test func exposesRepositoryFailure() async {
        let viewModel = LoginViewModel(repository: FakeAuthRepository(signInFailure: .invalidCredentials))
        viewModel.email = "user@mail.com"
        viewModel.password = "wrong"

        await viewModel.signIn()

        #expect(viewModel.failure == .invalidCredentials)
    }

    @Test func demoSignInSkipsValidation() async {
        let repository = FakeAuthRepository()
        let viewModel = LoginViewModel(repository: repository)

        await viewModel.signInWithDemo()

        #expect(repository.calls.signInWithDemo == 1)
        #expect(viewModel.emailIssue == nil)
    }

    @Test func tracksWhichSignInIsPending() async {
        let repository = SuspendedSignInRepository()
        let viewModel = LoginViewModel(repository: repository)

        let signIn = Task { await viewModel.signInWithDemo() }
        await repository.waitUntilCalled()

        #expect(viewModel.pendingMethod == .demo)
        #expect(viewModel.isSubmitting)

        repository.resume()
        await signIn.value
        #expect(viewModel.pendingMethod == nil)
    }
}

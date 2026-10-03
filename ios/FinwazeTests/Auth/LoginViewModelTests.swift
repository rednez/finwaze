import Testing
@testable import Finwaze

@MainActor
struct LoginViewModelTests {
    @Test func signsInWithGoogle() async {
        let repository = FakeAuthRepository()
        let viewModel = LoginViewModel(repository: repository)

        await viewModel.signInWithGoogle()

        #expect(repository.calls.signInWithGoogle == 1)
        #expect(viewModel.failure == nil)
        #expect(viewModel.pendingMethod == nil)
    }

    @Test func exposesGoogleFailure() async {
        let viewModel = LoginViewModel(repository: FakeAuthRepository(signInFailure: .network))

        await viewModel.signInWithGoogle()

        #expect(viewModel.failure == .network)
    }

    @Test func demoOpensDemoModeWithoutRepository() async {
        let repository = FakeAuthRepository()
        var demoEntered = 0
        let viewModel = LoginViewModel(repository: repository) { demoEntered += 1 }

        await viewModel.signInWithDemo()

        #expect(demoEntered == 1)
        #expect(repository.calls.signIn.isEmpty)
        #expect(repository.calls.signInWithGoogle == 0)
    }

    @Test func exposesDemoFailure() async {
        let viewModel = LoginViewModel(repository: FakeAuthRepository()) { () async throws(AuthFailure) in
            throw .network
        }

        await viewModel.signInWithDemo()

        #expect(viewModel.failure == .network)
        #expect(viewModel.pendingMethod == nil)
    }

    @Test func tracksWhichSignInIsPending() async {
        let repository = SuspendedSignInRepository()
        let viewModel = LoginViewModel(repository: repository)

        let signIn = Task { await viewModel.signInWithGoogle() }
        await repository.waitUntilCalled()

        #expect(viewModel.pendingMethod == .google)
        #expect(viewModel.isSubmitting)

        repository.resume()
        await signIn.value
        #expect(viewModel.pendingMethod == nil)
    }
}

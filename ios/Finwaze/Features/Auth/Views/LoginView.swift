import SwiftUI

/// The sign-in method picker (`AUTH-01`); email and password are on `EmailSignInView`.
struct LoginView: View {
  @State private var viewModel: LoginViewModel

  init(repository: any AuthRepository, enterDemo: @escaping () async throws(AuthFailure) -> Void = {}) {
    _viewModel = State(initialValue: LoginViewModel(repository: repository, enterDemo: enterDemo))
  }

  var body: some View {
    AuthScreen(title: "login.title", subtitle: "login.subtitle") {
      VStack(spacing: 12) {
        if viewModel.isGoogleSignInAvailable {
          googleButton
        }
        emailButton
      }

      demoButton

      AuthRedirectLink(prompt: "login.noAccount", linkLabel: "login.signUpLink", route: .signup)

      badge
    }
    .toolbarVisibility(.hidden, for: .navigationBar)
    .authFailureAlert($viewModel.failure, title: "login.error.title")
  }

  private var googleButton: some View {
    Button {
      Task { await viewModel.signInWithGoogle() }
    } label: {
      LoadingButtonLabel(isLoading: viewModel.pendingMethod == .google) {
        Label {
          Text("login.continueWithGoogle")
        } icon: {
          Image(.googleLogo)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
        }
      }
    }
    .buttonStyle(.glass)
    .disabled(viewModel.isSubmitting)
  }

  private var emailButton: some View {
    NavigationLink(value: AuthRoute.emailSignIn(email: "")) {
      LoadingButtonLabel(isLoading: false) {
        Label("login.signInWithEmail", systemImage: "envelope")
      }
    }
    .buttonStyle(.glass)
    .disabled(viewModel.isSubmitting)
  }

  private var demoButton: some View {
    Button {
      Task { await viewModel.signInWithDemo() }
    } label: {
      LoadingButtonLabel(isLoading: viewModel.pendingMethod == .demo) {
        Text("login.tryDemo")
          .foregroundStyle(
            LinearGradient(
              colors: [.brandGradientStart, .brandGradientEnd],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
      }
    }
    .buttonStyle(.glass)
    .disabled(viewModel.isSubmitting)
  }

  private var badge: some View {
    HStack(spacing: 8) {
      Circle()
        .fill(.tint)
        .frame(width: 6, height: 6)
      Text("login.badge")
        .font(.caption2.weight(.bold))
        .textCase(.uppercase)
        .tracking(2)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  NavigationStack {
    LoginView(repository: PreviewAuthRepository())
  }
}

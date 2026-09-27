import SwiftUI

struct LoginView: View {
  private enum Field {
    case email, password
  }

  @State private var viewModel: LoginViewModel
  @FocusState private var focusedField: Field?
  private let repository: any AuthRepository

  init(repository: any AuthRepository, enterDemo: @escaping () async -> Void = {}) {
    self.repository = repository
    _viewModel = State(initialValue: LoginViewModel(repository: repository, enterDemo: enterDemo))
  }

  var body: some View {
    AuthScreen(title: "login.title", subtitle: "login.subtitle") {
      VStack(spacing: 16) {
        credentialsForm

        AuthSubmitButton(
          title: "login.submit",
          isLoading: viewModel.pendingMethod == .email
        ) {
          submit()
        }
        .disabled(viewModel.isSubmitting)
        .padding(.top, 8)
      }

      demoButton

      AuthRedirectLink(prompt: "login.noAccount", linkLabel: "login.signUpLink")
      {
        // After sign-up the user comes back here with the email already filled in.
        SignupView(repository: repository) { email in
          viewModel.email = email
        }
      }

      badge
    }
    .toolbarVisibility(.hidden, for: .navigationBar)
    .authFailureAlert($viewModel.failure, title: "login.error.title")
  }

  private var credentialsForm: some View {
    VStack(spacing: 16) {
      FormField(
        label: "auth.email",
        error: viewModel.emailIssue?.message,
        isFocused: focusedField == .email
      ) {
        TextField("auth.emailPlaceholder", text: $viewModel.email)
          .textContentType(.username)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
          .submitLabel(.next)
          .focused($focusedField, equals: .email)
          .onSubmit { focusedField = .password }
      }

      FormField(
        label: "auth.password",
        error: viewModel.passwordIssue?.message,
        isFocused: focusedField == .password
      ) {
        PasswordField(
          prompt: "login.passwordPlaceholder",
          text: $viewModel.password
        )
        .submitLabel(.go)
        .focused($focusedField, equals: .password)
        .onSubmit(submit)
      }

      NavigationLink("login.forgotPassword") {
        // After requesting the link the user comes back here with the email already filled in.
        ResetPasswordView(repository: repository, email: viewModel.email) { email in
          viewModel.email = email
        }
      }
      .font(.subheadline.weight(.semibold))
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }

  private var demoButton: some View {
    Button {
      focusedField = nil
      Task { await viewModel.signInWithDemo() }
    } label: {
      let isLoading = viewModel.pendingMethod == .demo
      ZStack {
        Text("login.tryDemo")
          .foregroundStyle(
            LinearGradient(
              colors: [.brandGradientStart, .brandGradientEnd],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .opacity(isLoading ? 0 : 1)
        if isLoading {
          ProgressView()
        }
      }
      .font(.headline)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 6)
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

  private func submit() {
    focusedField = nil
    Task { await viewModel.signIn() }
  }
}

#Preview {
  NavigationStack {
    LoginView(repository: PreviewAuthRepository())
  }
}

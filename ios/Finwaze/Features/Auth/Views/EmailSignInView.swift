import SwiftUI

/// Email and password sign-in (`AUTH-02`), pushed from the login screen.
struct EmailSignInView: View {
  private enum Field {
    case email, password
  }

  @State private var viewModel: EmailSignInViewModel
  @FocusState private var focusedField: Field?

  init(repository: any AuthRepository, email: String) {
    _viewModel = State(initialValue: EmailSignInViewModel(repository: repository, email: email))
  }

  var body: some View {
    AuthScreen(title: "signin.title", subtitle: "signin.subtitle") {
      VStack(spacing: 16) {
        credentialsForm

        SubmitButton(title: "login.submit", isLoading: viewModel.isSubmitting) {
          submit()
        }
        .padding(.top, 8)
      }

      AuthRedirectLink(prompt: "login.noAccount", linkLabel: "login.signUpLink", route: .signup)
    }
    .navigationBarTitleDisplayMode(.inline)
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

      NavigationLink("login.forgotPassword", value: AuthRoute.resetPassword(email: viewModel.email))
        .font(.subheadline.weight(.semibold))
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }

  private func submit() {
    focusedField = nil
    Task { await viewModel.signIn() }
  }
}

#Preview {
  NavigationStack {
    EmailSignInView(repository: PreviewAuthRepository(), email: "")
  }
}

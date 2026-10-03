import SwiftUI

struct SignupView: View {
  private enum Field {
    case email, password, confirmation
  }

  @State private var viewModel: SignupViewModel
  @FocusState private var focusedField: Field?
  @Environment(\.dismiss) private var dismiss
  /// Called with the registered email when the user returns to sign in after confirming it;
  /// the caller navigates to the sign-in screen.
  private let onSignIn: (String) -> Void

  init(
    repository: any AuthRepository,
    onSignIn: @escaping (String) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: SignupViewModel(repository: repository))
    self.onSignIn = onSignIn
  }

  var body: some View {
    Group {
      if let email = viewModel.confirmationEmail {
        AuthScreen(title: "signup.checkEmail.title", subtitle: nil) {
          EmailSentView(
            message: "signup.verificationSent",
            hint: "signup.confirmHint",
            signInTitle: "signup.signInAfterConfirm",
            onSignIn: { onSignIn(email) },
            resend: .init(
              isResending: viewModel.isResending,
              didResend: viewModel.didResend,
              action: { Task { await viewModel.resendConfirmation() } }
            )
          )
        }
      } else {
        AuthScreen(title: "signup.title", subtitle: "signup.subtitle") {
          VStack(spacing: 16) {
            signupForm

            SubmitButton(
              title: "signup.submit",
              isLoading: viewModel.isSubmitting
            ) {
              submit()
            }
            .padding(.top, 8)
          }

          HStack(spacing: 4) {
            Text("signup.haveAccount")
              .foregroundStyle(.secondary)
            Button("signup.signInLink") { dismiss() }
              .fontWeight(.semibold)
          }
          .font(.subheadline)
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .authFailureAlert($viewModel.failure, title: "signup.error.title")
    .authFailureAlert($viewModel.resendFailure, title: "signup.resend.error.title")
  }

  private var signupForm: some View {
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
          prompt: "signup.passwordPlaceholder",
          text: $viewModel.password,
          textContentType: .newPassword
        )
        .submitLabel(.next)
        .focused($focusedField, equals: .password)
        .onSubmit { focusedField = .confirmation }
      }

      FormField(
        label: "signup.confirmPassword",
        error: viewModel.confirmationIssue?.message,
        isFocused: focusedField == .confirmation
      ) {
        PasswordField(
          prompt: "signup.confirmPlaceholder",
          text: $viewModel.confirmation,
          textContentType: .newPassword
        )
        .submitLabel(.go)
        .focused($focusedField, equals: .confirmation)
        .onSubmit(submit)
      }
    }
  }

  private func submit() {
    focusedField = nil
    Task { await viewModel.signUp() }
  }
}

#Preview {
  NavigationStack {
    SignupView(repository: PreviewAuthRepository())
  }
}

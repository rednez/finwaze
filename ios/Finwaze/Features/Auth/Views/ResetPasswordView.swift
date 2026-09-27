import SwiftUI

/// "Forgot password?" (`AUTH-08`). The link in the email opens the web client for now;
/// the screen tells the user to come back and sign in with the new password.
struct ResetPasswordView: View {
  @State private var viewModel: ResetPasswordViewModel
  @FocusState private var isEmailFocused: Bool
  @Environment(\.dismiss) private var dismiss
  /// Called with the email when the user goes back to sign in.
  private let onSignIn: (String) -> Void

  init(
    repository: any AuthRepository,
    email: String = "",
    onSignIn: @escaping (String) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: ResetPasswordViewModel(repository: repository, email: email))
    self.onSignIn = onSignIn
  }

  var body: some View {
    Group {
      if let email = viewModel.sentEmail {
        AuthScreen(title: "resetPassword.checkEmail.title", subtitle: nil) {
          EmailSentView(
            message: "resetPassword.sent",
            hint: "resetPassword.hint",
            signInTitle: "resetPassword.signIn",
            onSignIn: {
              onSignIn(email)
              dismiss()
            }
          )
        }
      } else {
        AuthScreen(title: "resetPassword.title", subtitle: "resetPassword.subtitle") {
          VStack(spacing: 16) {
            FormField(
              label: "auth.email",
              error: viewModel.emailIssue?.message,
              isFocused: isEmailFocused
            ) {
              TextField("auth.emailPlaceholder", text: $viewModel.email)
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.send)
                .focused($isEmailFocused)
                .onSubmit(submit)
            }

            AuthSubmitButton(title: "resetPassword.submit", isLoading: viewModel.isSubmitting) {
              submit()
            }
            .padding(.top, 8)
          }

          HStack(spacing: 4) {
            Text("resetPassword.rememberPassword")
              .foregroundStyle(.secondary)
            Button("signup.signInLink") { dismiss() }
            .fontWeight(.semibold)
          }
          .font(.subheadline)
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .authFailureAlert($viewModel.failure, title: "resetPassword.error.title")
  }

  private func submit() {
    isEmailFocused = false
    Task { await viewModel.sendLink() }
  }
}

#Preview {
  NavigationStack {
    ResetPasswordView(repository: PreviewAuthRepository())
  }
}

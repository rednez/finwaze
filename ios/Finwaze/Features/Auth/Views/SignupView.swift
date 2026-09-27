import SwiftUI

struct SignupView: View {
  private enum Field {
    case email, password, confirmation
  }

  @State private var viewModel: SignupViewModel
  @FocusState private var focusedField: Field?
  @Environment(\.dismiss) private var dismiss
  /// Called with the registered email when the user returns to sign in after confirming it.
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
          ConfirmationSentView(
            isResending: viewModel.isResending,
            didResend: viewModel.didResend,
            onResend: { Task { await viewModel.resendConfirmation() } },
            onSignIn: {
              onSignIn(email)
              dismiss()
            }
          )
        }
      } else {
        AuthScreen(title: "signup.title", subtitle: "signup.subtitle") {
          VStack(spacing: 16) {
            signupForm

            AuthSubmitButton(
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

/// Shown after sign-up: explains how to get back into the app and lets the user resend the email.
private struct ConfirmationSentView: View {
  let isResending: Bool
  let didResend: Bool
  let onResend: () -> Void
  let onSignIn: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      Label {
        VStack(spacing: 8) {
          Text("signup.verificationSent")
          Text("signup.confirmHint")
            .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
      } icon: {
        Image(systemName: "envelope.badge")
          .font(.largeTitle)
          .foregroundStyle(.green)
      }
      .labelStyle(VerticalLabelStyle())
      .padding(24)
      .frame(maxWidth: .infinity)
      .glassEffect(
        .regular.tint(.green.opacity(0.15)),
        in: .rect(cornerRadius: 24)
      )

      AuthSubmitButton(title: "signup.signInAfterConfirm", isLoading: false, action: onSignIn)
        .padding(.top, 8)

      Button(action: onResend) {
        ZStack {
          Text("signup.resend").opacity(isResending ? 0 : 1)
          if isResending {
            ProgressView()
          }
        }
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
      }
      .buttonStyle(.glass)
      .disabled(isResending)

      if didResend {
        Label("signup.resent", systemImage: "checkmark.circle.fill")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .transition(.opacity)
      }
    }
    .animation(.default, value: didResend)
  }
}

private struct VerticalLabelStyle: LabelStyle {
  func makeBody(configuration: Configuration) -> some View {
    VStack(spacing: 12) {
      configuration.icon
      configuration.title
    }
  }
}

#Preview {
  NavigationStack {
    SignupView(repository: PreviewAuthRepository())
  }
}

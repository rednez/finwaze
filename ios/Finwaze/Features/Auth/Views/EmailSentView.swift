import SwiftUI

/// "Check your email": explains how to get back into the app (`AUTH-05`, `AUTH-08`)
/// and, when `resend` is set, lets the user send the email again.
struct EmailSentView: View {
  struct Resend {
    let isResending: Bool
    let didResend: Bool
    let action: () -> Void
  }

  let message: LocalizedStringKey
  let hint: LocalizedStringKey
  let signInTitle: LocalizedStringKey
  let onSignIn: () -> Void
  var resend: Resend?

  var body: some View {
    VStack(spacing: 16) {
      Label {
        VStack(spacing: 8) {
          Text(message)
          Text(hint)
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

      SubmitButton(title: signInTitle, isLoading: false, action: onSignIn)
        .padding(.top, 8)

      if let resend {
        ResendButton(resend: resend)
      }
    }
  }
}

private struct ResendButton: View {
  let resend: EmailSentView.Resend

  var body: some View {
    VStack(spacing: 16) {
      Button(action: resend.action) {
        ZStack {
          Text("signup.resend").opacity(resend.isResending ? 0 : 1)
          if resend.isResending {
            ProgressView()
          }
        }
        .font(.headline)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
      }
      .buttonStyle(.glass)
      .disabled(resend.isResending)

      if resend.didResend {
        Label("signup.resent", systemImage: "checkmark.circle.fill")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .transition(.opacity)
      }
    }
    .animation(.default, value: resend.didResend)
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
  EmailSentView(
    message: "signup.verificationSent",
    hint: "signup.confirmHint",
    signInTitle: "signup.signInAfterConfirm",
    onSignIn: {},
    resend: .init(isResending: false, didResend: true, action: {})
  )
  .padding()
}

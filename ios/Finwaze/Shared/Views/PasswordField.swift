import SwiftUI

/// A secure text field with a button that reveals the password.
struct PasswordField: View {
    let prompt: LocalizedStringKey
    @Binding var text: String
    var textContentType: UITextContentType = .password

    @State private var isRevealed = false

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isRevealed {
                    TextField(prompt, text: $text)
                } else {
                    SecureField(prompt, text: $text)
                }
            }
            .textContentType(textContentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text(isRevealed ? "auth.hidePassword" : "auth.showPassword"))
        }
    }
}

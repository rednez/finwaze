import SwiftUI
import UIKit

/// A brief confirmation banner ("Transaction updated") that announces itself to VoiceOver and disappears on its
/// own (`TX-41`).
struct SuccessBanner: View {
    let message: LocalizedStringResource
    let onDismiss: () -> Void

    var body: some View {
        Label {
            Text(message)
        } icon: {
            Image(systemName: "checkmark.circle.fill")
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassEffect(.regular.tint(.green.opacity(0.15)), in: .capsule)
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
        .accessibilityElement(children: .combine)
        .task {
            UIAccessibility.post(notification: .announcement, argument: String(localized: message))
            try? await Task.sleep(for: .seconds(2))
            withAnimation { onDismiss() }
        }
    }
}

#Preview {
    SuccessBanner(message: "transactionForm.updateSucceeded") {}
}

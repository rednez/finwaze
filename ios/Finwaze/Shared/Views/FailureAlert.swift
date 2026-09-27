import SwiftUI

extension View {
    /// "Failed to …" with the server's explanation (`GEN-19`).
    func failureAlert(_ failure: Binding<String?>, title: LocalizedStringKey) -> some View {
        alert(
            title,
            isPresented: Binding(
                get: { failure.wrappedValue != nil },
                set: { if !$0 { failure.wrappedValue = nil } }
            ),
            presenting: failure.wrappedValue
        ) { _ in
            Button("common.ok", role: .cancel) {}
        } message: { message in
            Text(verbatim: message)
        }
    }
}

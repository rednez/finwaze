import SwiftUI

extension View {
    /// Loads the widget when it appears, and again when its month, its currency or the data change (`ACC-06`,
    /// `GEN-26`).
    func loads<Value>(_ widget: WalletWidgetViewModel<Value>, dataVersion: Int) -> some View {
        task(for: widget.key, dataVersion: dataVersion) {
            await widget.load(dataVersion: dataVersion)
        }
    }
}

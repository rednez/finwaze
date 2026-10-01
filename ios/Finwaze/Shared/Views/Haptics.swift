import UIKit

/// Haptic feedback for moments the user should feel, as the HIG suggests (Playing haptics): a saved or deleted record,
/// a step through the periods. Views that stay on screen use `sensoryFeedback`; this is for the actions that close
/// their screen at the same moment, before a trigger could fire.
enum Haptics {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

import Foundation
import Observation

/// Moves through the tour: 6 informational steps, then the first-account step (`ONB-01…03`).
@Observable
final class OnboardingViewModel {
    let infoStepCount: Int
    /// Zero-based; `infoStepCount` is the account step.
    var step = 0

    init(infoStepCount: Int = OnboardingInfoStep.all.count) {
        self.infoStepCount = infoStepCount
    }

    /// Informational steps plus the account step: "Step N of 7".
    var stepCount: Int {
        infoStepCount + 1
    }

    var isAccountStep: Bool {
        step == infoStepCount
    }

    /// On the last informational step "Next" reads "Get started" (`ONB-03`).
    var isLastInfoStep: Bool {
        step == infoStepCount - 1
    }

    var canGoBack: Bool {
        step > 0
    }

    func next() {
        go(to: step + 1)
    }

    func back() {
        go(to: step - 1)
    }

    /// Straight to the account step.
    func skip() {
        go(to: infoStepCount)
    }

    func go(to step: Int) {
        self.step = min(max(step, 0), infoStepCount)
    }
}

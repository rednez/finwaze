import Testing
@testable import Finwaze

@MainActor
struct OnboardingViewModelTests {
    @Test func tourHasSixInfoStepsAndTheAccountStep() {
        let viewModel = OnboardingViewModel()

        #expect(viewModel.step == 0)
        #expect(viewModel.stepCount == 7)
        #expect(!viewModel.canGoBack)
        #expect(!viewModel.isAccountStep)
    }

    @Test func nextAndBackMoveOneStep() {
        let viewModel = OnboardingViewModel()

        viewModel.next()
        viewModel.next()
        #expect(viewModel.step == 2)

        viewModel.back()
        #expect(viewModel.step == 1)
        #expect(viewModel.canGoBack)
    }

    @Test func staysWithinTheTour() {
        let viewModel = OnboardingViewModel()

        viewModel.back()
        #expect(viewModel.step == 0)

        viewModel.go(to: 6)
        viewModel.next()
        #expect(viewModel.step == 6)
        #expect(viewModel.isAccountStep)
    }

    @Test func skipGoesStraightToTheAccountStep() {
        let viewModel = OnboardingViewModel()
        viewModel.next()

        viewModel.skip()

        #expect(viewModel.isAccountStep)
    }

    @Test func dotsOpenAnyStep() {
        let viewModel = OnboardingViewModel()

        viewModel.go(to: 4)
        #expect(viewModel.step == 4)

        viewModel.go(to: 1)
        #expect(viewModel.step == 1)
    }

    @Test func nextReadsGetStartedOnlyOnTheSixthStep() {
        let viewModel = OnboardingViewModel()

        let lastInfoSteps = (0..<6).map { step in
            viewModel.go(to: step)
            return viewModel.isLastInfoStep
        }

        #expect(lastInfoSteps == [false, false, false, false, false, true])
        viewModel.next()
        #expect(viewModel.isAccountStep)
        #expect(!viewModel.isLastInfoStep)
    }
}

import SwiftUI

/// One informational page of the tour (`ONB-01`); texts are the web client's (`misc.onboarding.steps`).
struct OnboardingInfoStep: Identifiable {
    let id: String
    /// Light and dark variants live in one image set; the system picks the one for the current appearance.
    let image: ImageResource
    let eyebrow: LocalizedStringResource
    let title: LocalizedStringResource
    let description: LocalizedStringResource
    let bullets: [LocalizedStringResource]

    // Literal keys, not interpolated ones: an interpolated key becomes a format and never matches the catalog.
    static let all: [OnboardingInfoStep] = [
        OnboardingInfoStep(
            id: "welcome",
            image: .onboardingWelcome,
            eyebrow: "onboarding.welcome.eyebrow",
            title: "onboarding.welcome.title",
            description: "onboarding.welcome.description",
            bullets: ["onboarding.welcome.bullet1", "onboarding.welcome.bullet2", "onboarding.welcome.bullet3"]
        ),
        OnboardingInfoStep(
            id: "transactions",
            image: .onboardingTransactions,
            eyebrow: "onboarding.transactions.eyebrow",
            title: "onboarding.transactions.title",
            description: "onboarding.transactions.description",
            bullets: [
                "onboarding.transactions.bullet1", "onboarding.transactions.bullet2", "onboarding.transactions.bullet3",
            ]
        ),
        OnboardingInfoStep(
            id: "categories",
            image: .onboardingCategories,
            eyebrow: "onboarding.categories.eyebrow",
            title: "onboarding.categories.title",
            description: "onboarding.categories.description",
            bullets: ["onboarding.categories.bullet1", "onboarding.categories.bullet2", "onboarding.categories.bullet3"]
        ),
        OnboardingInfoStep(
            id: "budget",
            image: .onboardingBudget,
            eyebrow: "onboarding.budget.eyebrow",
            title: "onboarding.budget.title",
            description: "onboarding.budget.description",
            bullets: ["onboarding.budget.bullet1", "onboarding.budget.bullet2", "onboarding.budget.bullet3"]
        ),
        OnboardingInfoStep(
            id: "goals",
            image: .onboardingGoals,
            eyebrow: "onboarding.goals.eyebrow",
            title: "onboarding.goals.title",
            description: "onboarding.goals.description",
            bullets: ["onboarding.goals.bullet1", "onboarding.goals.bullet2", "onboarding.goals.bullet3"]
        ),
        OnboardingInfoStep(
            id: "analytics",
            image: .onboardingAnalytics,
            eyebrow: "onboarding.analytics.eyebrow",
            title: "onboarding.analytics.title",
            description: "onboarding.analytics.description",
            bullets: ["onboarding.analytics.bullet1", "onboarding.analytics.bullet2", "onboarding.analytics.bullet3"]
        ),
    ]
}

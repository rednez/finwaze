import SwiftUI

/// The last step: create the first account (`ONB-02`, `ONB-04`).
struct OnboardingAccountStepView: View {
    @Bindable var viewModel: AccountFormViewModel
    let currencies: [Currency]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                OnboardingHeading(
                    eyebrow: "onboarding.account.eyebrow",
                    title: "onboarding.account.title",
                    description: "onboarding.account.description"
                )

                AccountFormFields(viewModel: viewModel, currencies: currencies, onSubmit: submit)

                SubmitButton(title: "onboarding.account.create", isLoading: viewModel.isSubmitting, action: submit)

                guideHint
            }
            .padding(24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var guideHint: some View {
        Label {
            Text("onboarding.account.guideHint")
                .foregroundStyle(.secondary)
        } icon: {
            Image(systemName: "safari")
                .foregroundStyle(.tint)
        }
        .font(.subheadline)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.tint.opacity(0.08), in: .rect(cornerRadius: 16))
    }

    private func submit() {
        Task { await viewModel.submit() }
    }
}

#Preview {
    OnboardingAccountStepView(
        viewModel: AccountFormViewModel(repository: DemoReferenceDataRepository()) { _ in },
        currencies: DemoData.currencies
    )
}

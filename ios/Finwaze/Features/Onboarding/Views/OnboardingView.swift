import SwiftUI

/// First-time setup for a user without a regular account (`NAV-07`): the tour, then the first account
/// (`ONB-01…05`). The only way out without creating an account is signing out (`ONB-05`).
struct OnboardingView: View {
    let currencies: [Currency]
    let onSignOut: () -> Void
    @State private var viewModel = OnboardingViewModel()
    @State private var accountForm: AccountFormViewModel

    init(app: AppViewModel, onSignOut: @escaping () -> Void) {
        currencies = app.referenceData.currencies
        self.onSignOut = onSignOut
        // Success reloads reference data, which switches the app to the Dashboard (`ONB-04`).
        _accountForm = State(
            initialValue: AccountFormViewModel(repository: app.repositories.accounts, onCreated: app.accountCreated)
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            TabView(selection: $viewModel.step) {
                ForEach(Array(OnboardingInfoStep.all.enumerated()), id: \.element.id) { index, step in
                    OnboardingInfoStepView(step: step)
                        .tag(index)
                }
                OnboardingAccountStepView(viewModel: accountForm, currencies: currencies)
                    .tag(viewModel.infoStepCount)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            footer
        }
        .background { BrandBackground() }
        .animation(.default, value: viewModel.step)
        .accountCreationFailureAlert($accountForm.failure, title: "onboarding.account.creationFailed")
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Text("onboarding.stepCounter \(viewModel.step + 1) \(viewModel.stepCount)")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                Spacer()
                Button("profile.signOut", systemImage: "rectangle.portrait.and.arrow.right", action: onSignOut)
                    .labelStyle(.titleOnly)
                    .buttonStyle(.glass)
            }
            OnboardingProgress(viewModel: viewModel)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if viewModel.canGoBack {
                Button("onboarding.back", systemImage: "chevron.backward", action: viewModel.back)
                    .labelStyle(.titleOnly)
                    .buttonStyle(.glass)
            }
            Spacer()
            if !viewModel.isAccountStep {
                Button("onboarding.skip", action: viewModel.skip)
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                Button(viewModel.isLastInfoStep ? "onboarding.getStarted" : "onboarding.next", action: viewModel.next)
                    .buttonStyle(.glassProminent)
            }
        }
        .controlSize(.large)
        .disabled(accountForm.isSubmitting)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

/// "Step N of 7" dots; each dot opens its step (`ONB-03`).
private struct OnboardingProgress: View {
    let viewModel: OnboardingViewModel

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<viewModel.stepCount, id: \.self) { index in
                let isActive = index == viewModel.step
                Button {
                    viewModel.go(to: index)
                } label: {
                    Capsule()
                        .fill(isActive ? AnyShapeStyle(.tint) : AnyShapeStyle(.quaternary))
                        .frame(width: isActive ? 24 : 8, height: 8)
                        .frame(maxWidth: .infinity, minHeight: 24)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("onboarding.goToStep \(index + 1)"))
                .accessibilityAddTraits(isActive ? .isSelected : [])
            }
        }
        .frame(maxWidth: 360)
    }
}

#Preview {
    OnboardingView(app: .preview, onSignOut: {})
}

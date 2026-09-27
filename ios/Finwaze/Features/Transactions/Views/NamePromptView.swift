import SwiftUI

/// "New group" or "New category" (`TX-12`): a name, an optional colour (`CAT-10`) and "Create". Closes itself on
/// success.
struct NamePromptView: View {
    let title: LocalizedStringKey
    let failureTitle: LocalizedStringKey
    @State private var viewModel: NamePromptViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    init(
        title: LocalizedStringKey,
        failureTitle: LocalizedStringKey,
        create: @escaping (_ name: String, _ color: String?) async throws -> Void
    ) {
        self.title = title
        self.failureTitle = failureTitle
        _viewModel = State(initialValue: NamePromptViewModel(create: create))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    FormField(label: "namePrompt.name", error: viewModel.nameIssue?.message, isFocused: isFocused) {
                        TextField("namePrompt.placeholder", text: $viewModel.name)
                            .textInputAutocapitalization(.sentences)
                            .submitLabel(.done)
                            .focused($isFocused)
                            .onSubmit(submit)
                    }
                    .disabled(viewModel.isSubmitting)

                    ColorPaletteField(selection: $viewModel.color)
                        .disabled(viewModel.isSubmitting)

                    SubmitButton(title: "namePrompt.create", isLoading: viewModel.isSubmitting, action: submit)
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel", role: .cancel) { dismiss() }
                        .disabled(viewModel.isSubmitting)
                }
            }
            .failureAlert($viewModel.failure, title: failureTitle)
            .onAppear { isFocused = true }
        }
        .presentationDetents([.large])
        .interactiveDismissDisabled(viewModel.isSubmitting)
    }

    private func submit() {
        Task {
            if await viewModel.submit() {
                dismiss()
            }
        }
    }
}

#Preview {
    NamePromptView(title: "categoryPicker.newGroup", failureTitle: "categoryPicker.groupCreationFailed") { _, _ in }
}

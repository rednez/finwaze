import SwiftUI

/// "New group", "New category" or editing one (`TX-12`, `CAT-04…08`): a name, an optional colour (`CAT-10`), the type
/// of a new group when asked (`CAT-04`) and "Create" or "Save". Closes itself on success.
struct NamePromptView: View {
    let title: LocalizedStringKey
    let failureTitle: LocalizedStringKey
    let submitTitle: LocalizedStringKey
    @State private var viewModel: NamePromptViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    init(
        title: LocalizedStringKey,
        failureTitle: LocalizedStringKey,
        submitTitle: LocalizedStringKey = "namePrompt.create",
        name: String = "",
        color: String? = nil,
        type: TransactionType? = nil,
        save: @escaping (NamePromptViewModel.Input) async throws -> Void
    ) {
        self.title = title
        self.failureTitle = failureTitle
        self.submitTitle = submitTitle
        _viewModel = State(initialValue: NamePromptViewModel(name: name, color: color, type: type, save: save))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if viewModel.type != nil {
                        Picker("namePrompt.type", selection: $viewModel.type) {
                            Text("transactionType.expense").tag(TransactionType?.some(.expense))
                            Text("transactionType.income").tag(TransactionType?.some(.income))
                        }
                        .pickerStyle(.segmented)
                        .disabled(viewModel.isSubmitting)
                    }

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

                    SubmitButton(title: submitTitle, isLoading: viewModel.isSubmitting, action: submit)
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
    NamePromptView(title: "categoryPicker.newGroup", failureTitle: "categoryPicker.groupCreationFailed", type: .expense) { _ in }
}

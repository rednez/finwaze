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

                    NameBadgePreview(name: viewModel.name, color: viewModel.color)

                    FormSection {
                        FormRow(label: "namePrompt.name", systemImage: "character.cursor.ibeam", tint: .blue, error: viewModel.nameIssue?.message) {
                            TextField("namePrompt.placeholder", text: $viewModel.name)
                                .textInputAutocapitalization(.sentences)
                                .submitLabel(.done)
                                .focused($isFocused)
                                .onSubmit(submit)
                                .accessibilityLabel(Text("namePrompt.name"))
                        }
                    }
                    .disabled(viewModel.isSubmitting)

                    ColorPaletteField(selection: $viewModel.color)
                        .disabled(viewModel.isSubmitting)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .animation(.snappy, value: viewModel.color)
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
                FormConfirmItem(title: submitTitle, isSubmitting: viewModel.isSubmitting, action: submit)
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
                Haptics.success()
                dismiss()
            }
        }
    }
}

/// How the group or category will look — its initial on its colour — as the name and colour are chosen.
private struct NameBadgePreview: View {
    let name: String
    let color: String?
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 76

    private var tint: Color {
        color.flatMap(Color.init(hex:)) ?? Color(.systemGray3)
    }

    var body: some View {
        Text(verbatim: name.trimmingCharacters(in: .whitespaces).prefix(1).uppercased())
            .font(.largeTitle.weight(.bold))
            .fontDesign(.rounded)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(tint.gradient, in: .rect(cornerRadius: size * 0.3, style: .continuous))
            .shadow(color: tint.opacity(0.35), radius: 12, y: 6)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .accessibilityHidden(true)
    }
}

#Preview {
    NamePromptView(title: "categoryPicker.newGroup", failureTitle: "categoryPicker.groupCreationFailed", type: .expense) { _ in }
}

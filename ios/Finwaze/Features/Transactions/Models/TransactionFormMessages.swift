import Foundation

/// User-facing texts for transaction form and name prompt validation issues.
extension TransactionFormViewModel.RequiredIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.required"
        }
    }
}

extension TransactionFormViewModel.AmountIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.amountRequired"
        case .notPositive: "transactionForm.amountNotPositive"
        case .tooPrecise: "transactionForm.amountTooPrecise"
        case .equalsChargedAmount: "transactionForm.amountEqualsCharged"
        case .equalsExpenseAmount: "transactionForm.amountEqualsExpense"
        }
    }
}

extension TransactionFormViewModel.CommentIssue {
    var message: LocalizedStringResource {
        switch self {
        case .tooLong: "transactionForm.commentTooLong"
        }
    }
}

extension NamePromptViewModel.NameIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "namePrompt.nameRequired"
        case .tooLong: "namePrompt.nameTooLong"
        }
    }
}

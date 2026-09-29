import Foundation

/// User-facing texts for transaction form and name prompt validation issues.
extension TransactionFormViewModel.AmountIssue {
    var message: LocalizedStringResource {
        switch self {
        case .input(let issue): issue.message
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

import Foundation

/// User-facing texts for transfer form validation issues.
extension TransferFormViewModel.AccountIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.required"
        }
    }
}

extension TransferFormViewModel.DateIssue {
    var message: LocalizedStringResource {
        switch self {
        case .inFuture: "transferForm.dateInFuture"
        }
    }
}

extension PositiveAmountInput.Issue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.amountRequired"
        case .notPositive: "transactionForm.amountNotPositive"
        case .tooPrecise: "transactionForm.amountTooPrecise"
        }
    }
}

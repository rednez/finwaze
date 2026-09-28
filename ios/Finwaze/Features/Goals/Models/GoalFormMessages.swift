import Foundation

/// User-facing texts for the goal forms' validation issues.
extension GoalFormViewModel.NameIssue {
    var message: LocalizedStringResource {
        switch self {
        case .length: "goals.form.nameError"
        }
    }
}

extension GoalFormViewModel.AmountIssue {
    var message: LocalizedStringResource {
        switch self {
        case .input(let issue): issue.message
        case .belowMinimum: "goals.form.targetBelowMinimum"
        }
    }
}

extension GoalFormViewModel.DateIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "goals.form.targetDateRequired"
        case .inPast: "goals.form.targetDateInPast"
        }
    }
}

extension GoalFormViewModel.CurrencyIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.required"
        }
    }
}

extension GoalTransferViewModel.AccountIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.required"
        }
    }
}

extension GoalTransferViewModel.AmountIssue {
    var message: LocalizedStringResource {
        switch self {
        case .input(let issue): issue.message
        case .exceedsSaved: "goals.transfer.exceedsSaved"
        }
    }
}

extension GoalTransferViewModel.DateIssue {
    var message: LocalizedStringResource {
        switch self {
        case .inFuture: "transferForm.dateInFuture"
        }
    }
}

extension GoalClosingViewModel.AccountIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.required"
        }
    }
}

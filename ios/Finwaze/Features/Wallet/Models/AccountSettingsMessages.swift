import Foundation

/// User-facing texts for account settings validation issues.
extension SignedAmountInput.Issue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "accountSettings.balanceRequired"
        case .invalid: "accountSettings.balanceInvalid"
        case .tooPrecise: "transactionForm.amountTooPrecise"
        }
    }
}

extension AccountSettingsViewModel.DateIssue {
    var message: LocalizedStringResource {
        switch self {
        case .inFuture: "transferForm.dateInFuture"
        }
    }
}

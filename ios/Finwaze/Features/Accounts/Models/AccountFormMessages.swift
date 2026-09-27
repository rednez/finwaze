import Foundation

/// User-facing texts for account form validation issues.
extension AccountFormViewModel.NameIssue {
    var message: LocalizedStringResource {
        switch self {
        case .length: "accountForm.nameError"
        }
    }
}

extension AccountFormViewModel.CurrencyIssue {
    var message: LocalizedStringResource {
        switch self {
        case .required: "accountForm.currencyError"
        }
    }
}

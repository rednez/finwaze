import Foundation

/// A field that must be filled — an account, category or currency not picked yet (`GEN-21`).
enum RequiredIssue: Equatable {
    case required

    var message: LocalizedStringResource {
        switch self {
        case .required: "transactionForm.required"
        }
    }
}

/// A moment that cannot be later than now (`GEN-13`).
enum FutureDateIssue: Equatable {
    case inFuture

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

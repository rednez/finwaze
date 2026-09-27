import Foundation

/// Mirrors `public.transaction_type`. Groups are only ever `income` or `expense`.
nonisolated enum TransactionType: String, Codable, Sendable {
    case income
    case expense
    case transfer
    case `internal`
}

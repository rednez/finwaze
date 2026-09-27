import Foundation

protocol TransfersRepository: Sendable {
    /// Moves money between two regular accounts (`TRF-01…05`).
    func make(_ transfer: NewTransfer) async throws
    /// Both sides of the transfer that `transactionID` belongs to, fresh from the server (`TRF-07`); `nil` when it no
    /// longer exists.
    func transfer(transactionID: Int64) async throws -> Transfer?
    /// Deletes both records of a transfer (`TRF-08`); deleting one that is already gone still succeeds.
    func delete(transferID: UUID) async throws
}

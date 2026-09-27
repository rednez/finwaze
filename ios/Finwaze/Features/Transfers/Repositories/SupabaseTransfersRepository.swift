import Foundation
import Supabase

nonisolated struct SupabaseTransfersRepository: TransfersRepository {
    let client: SupabaseClient

    private struct DetailsParams: Encodable {
        let transactionID: Int64

        enum CodingKeys: String, CodingKey {
            case transactionID = "p_transaction_id"
        }
    }

    func make(_ transfer: NewTransfer) async throws {
        try await client
            .rpc("make_transfer", params: TransferMapper.toDto(transfer))
            .execute()
    }

    func transfer(transactionID: Int64) async throws -> Transfer? {
        // The same columns as `get_filtered_transactions`, so the list's DTO and mapper apply.
        let dtos: [TransactionDto] = try await client
            .rpc("get_transfer_transactions", params: DetailsParams(transactionID: transactionID))
            .execute()
            .value
        return TransferMapper.toTransfer(try dtos.map(TransactionMapper.toTransaction))
    }

    func delete(transferID: UUID) async throws {
        try await client
            .from("transactions")
            .delete()
            .eq("transfer_id", value: transferID.uuidString.lowercased())
            .execute()
    }
}

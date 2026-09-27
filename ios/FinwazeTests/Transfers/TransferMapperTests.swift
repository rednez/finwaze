import Foundation
import Testing
@testable import Finwaze

struct TransferMapperTests {
    private let transferID = UUID(uuidString: "3F2504E0-4F89-41D3-9A0C-0305E82C3301")!

    private func record(id: Int64, amount: Decimal, transferID: UUID? = nil) -> Transaction {
        .transferRecord(
            id: id, transferID: transferID ?? self.transferID, amount: amount, currencyCode: "UAH",
            accountID: id, accountName: "Account \(id)"
        )
    }

    @Test func pairsSentAndReceivedInAnyOrder() throws {
        let transfer = try #require(TransferMapper.toTransfer([record(id: 2, amount: 4150), record(id: 1, amount: -100)]))

        #expect(transfer.id == transferID)
        #expect(transfer.sent.id == 1)
        #expect(transfer.received.id == 2)
        #expect(transfer.sentAmount == 100)
        #expect(transfer.receivedAmount == 4150)
    }

    @Test func exchangeRateIsReceivedOverSentInDecimal() throws {
        let transfer = try #require(TransferMapper.toTransfer([record(id: 1, amount: -100), record(id: 2, amount: 4300)]))

        #expect(transfer.exchangeRate == 43)
    }

    @Test func incompletePairIsNotATransfer() {
        #expect(TransferMapper.toTransfer([]) == nil)
        #expect(TransferMapper.toTransfer([record(id: 1, amount: -100)]) == nil)
        #expect(TransferMapper.toTransfer([record(id: 2, amount: 100)]) == nil)
    }

    @Test func recordsOfDifferentTransfersDoNotPair() {
        let other = UUID()

        #expect(TransferMapper.toTransfer([record(id: 1, amount: -100), record(id: 2, amount: 100, transferID: other)]) == nil)
    }

    @Test func dtoUsesTheFunctionsParameterNames() throws {
        let transfer = NewTransfer(
            fromAccountID: 1, toAccountID: 2, fromAmount: Decimal(string: "100.5")!, toAmount: 4300,
            transactedAt: Date(timeIntervalSince1970: 1_790_500_500), localOffset: LocalOffset(seconds: 10_800)
        )

        let json = try #require(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(TransferMapper.toDto(transfer))) as? [String: Any]
        )

        #expect(json["p_from_account_id"] as? Int == 1)
        #expect(json["p_to_account_id"] as? Int == 2)
        #expect((json["p_from_amount"] as? NSNumber)?.decimalValue == Decimal(string: "100.5"))
        #expect((json["p_to_amount"] as? NSNumber)?.decimalValue == 4300)
        #expect(json["p_local_offset"] as? String == "+03:00")
        #expect(json["p_transacted_at"] as? String == "2026-09-27T09:15:00.000Z")
        #expect(json["p_comment"] == nil)
    }

    /// Same currency: `p_to_amount` is left out, so the server uses the sent amount (`TRF-03`).
    @Test func dtoLeavesOutAMissingReceivedAmount() throws {
        let transfer = NewTransfer(
            fromAccountID: 1, toAccountID: 2, fromAmount: 100, toAmount: nil,
            transactedAt: .now, localOffset: LocalOffset(seconds: 0)
        )

        let json = try #require(
            JSONSerialization.jsonObject(with: JSONEncoder().encode(TransferMapper.toDto(transfer))) as? [String: Any]
        )

        #expect(json.keys.contains("p_to_amount") == false)
    }
}

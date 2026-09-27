import Foundation
import Testing
@testable import Finwaze

struct TransactionMapperTests {
    private func row(
        transactedAt: String = "2026-09-27T09:15:00+00:00",
        offset: String = "03:00:00",
        amount: String = "-250",
        comment: String = "null"
    ) -> String {
        #"""
        {"id": 7, "transacted_at": "\#(transactedAt)", "local_offset": "\#(offset)",
         "transaction_amount": \#(amount), "transaction_currency_code": "UAH",
         "account_id": 2, "account_name": "Cash", "charged_amount": \#(amount), "charged_currency_code": "UAH",
         "exchange_rate": 1, "type": "expense",
         "group_id": 1, "group_name": "Food", "group_color": "#22C55E",
         "category_id": 3, "category_name": "Groceries", "category_color": null,
         "comment": \#(comment), "transfer_id": null}
        """#
    }

    private func map(_ json: String) throws -> Transaction {
        try TransactionMapper.toTransaction(JSONDecoder().decode(TransactionDto.self, from: Data(json.utf8)))
    }

    @Test func mapsRow() throws {
        let transaction = try map(row())

        #expect(transaction.id == 7)
        #expect(transaction.type == .expense)
        #expect(transaction.transactedAt == Date(timeIntervalSince1970: 1_790_500_500))
        #expect(transaction.localOffset == LocalOffset(seconds: 10_800))
        #expect(transaction.transactionAmount == -250)
        #expect(transaction.accountName == "Cash")
        #expect(transaction.group == Transaction.Label(id: 1, name: "Food", color: "#22C55E"))
        #expect(transaction.category == Transaction.Label(id: 3, name: "Groceries", color: nil))
        #expect(transaction.comment == nil)
        #expect(!transaction.isForeignCurrency)
    }

    /// `NUMERIC` from PostgREST must reach `Decimal` without a detour through `Double`.
    @Test(arguments: ["0.1", "-0.3", "-12.5", "1234567.89", "-99999999999999.99"])
    func decodesNumericWithoutLosingPrecision(_ text: String) throws {
        let expected = try #require(Decimal(string: text, locale: Locale(identifier: "en_US_POSIX")))

        #expect(try map(row(amount: text)).transactionAmount == expected)
    }

    @Test(arguments: [
        ("2026-09-27T09:15:00+00:00", 0.0),
        ("2026-09-27T09:15:00.5+00:00", 0.5),
        ("2026-09-27T09:15:00.123456+00:00", 0.123),
        ("2026-09-27T12:15:00+03:00", 0.0),
    ])
    func parsesTimestamps(_ text: String, fraction: Double) throws {
        let date = try #require(TransactionMapper.parseTimestamp(text))

        #expect(abs(date.timeIntervalSince1970 - (1_790_500_500 + fraction)) < 0.001)
    }

    @Test func keepsNegativeOffset() throws {
        #expect(try map(row(offset: "-05:30:00")).localOffset.seconds == -19_800)
    }

    /// A wrong offset would silently move the transaction to another day, so the row is rejected instead.
    @Test func rejectsUnknownOffset() {
        #expect(throws: TransactionMapper.MappingError.invalidOffset("2 hours")) {
            try map(row(offset: "2 hours"))
        }
    }

    @Test func emptyCommentIsNoComment() throws {
        #expect(try map(row(comment: #""""#)).comment == nil)
        #expect(try map(row(comment: #""Lunch""#)).comment == "Lunch")
    }

    @Test func encodesNewTransactionExactly() throws {
        let transaction = NewTransaction(
            type: .expense,
            transactedAt: Date(timeIntervalSince1970: 1_790_500_500),
            localOffset: LocalOffset(seconds: 10_800),
            accountID: 2,
            categoryID: 3,
            transactionAmount: Decimal(string: "0.1")!,
            transactionCurrencyID: 5,
            chargedAmount: Decimal(string: "0.1")!,
            comment: nil
        )

        let data = try JSONEncoder().encode(TransactionMapper.toDto(transaction))
        let json = try #require(String(data: data, encoding: .utf8))
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(json.contains(#""transaction_amount":0.1"#))
        #expect(json.contains(#""charged_amount":0.1"#))
        #expect(object["transacted_at"] as? String == "2026-09-27T09:15:00.000Z")
        #expect(object["local_offset"] as? String == "+03:00")
        #expect(object["type"] as? String == "expense")
        #expect(object["transaction_currency_id"] as? Int == 5)
        #expect(object["comment"] == nil)
    }
}

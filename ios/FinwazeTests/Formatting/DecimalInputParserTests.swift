import Foundation
import Testing
@testable import Finwaze

struct DecimalInputParserTests {
    @Test(arguments: [
        ("250", "250", 0),
        ("0,1", "0.1", 1),
        ("0.1", "0.1", 1),
        ("1 250,50", "1250.5", 2),
        ("1\u{00A0}250,50", "1250.5", 2),
        (" 12.345 ", "12.345", 3),
        ("0", "0", 0),
    ])
    func parsesNumbers(_ text: String, expected: String, fractionDigits: Int) throws {
        let value = try #require(Decimal(string: expected, locale: Locale(identifier: "en_US_POSIX")))

        #expect(DecimalInputParser.parse(text) == .value(value, fractionDigits: fractionDigits))
    }

    @Test(arguments: ["", "   "])
    func emptyTextIsEmpty(_ text: String) {
        #expect(DecimalInputParser.parse(text) == .empty)
    }

    @Test(arguments: ["-5", "+5", "abc", "1,2,3", "1.250,50", ",5", "5,", "1e3"])
    func rejectsAnythingElse(_ text: String) {
        #expect(DecimalInputParser.parse(text) == .invalid)
    }

    /// `GEN-09`: 0.1 + 0.2 is exactly 0.3.
    @Test func keepsDecimalPrecision() throws {
        guard
            case .value(let a, _) = DecimalInputParser.parse("0,1"),
            case .value(let b, _) = DecimalInputParser.parse("0.2")
        else {
            Issue.record("Expected values")
            return
        }
        #expect(a + b == Decimal(string: "0.3", locale: Locale(identifier: "en_US_POSIX")))
    }
}

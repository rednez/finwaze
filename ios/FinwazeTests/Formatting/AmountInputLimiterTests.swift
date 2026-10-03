import Testing
@testable import Finwaze

struct AmountInputLimiterTests {
    @Test(arguments: [
        ("12,345", "12,34"),
        ("12.3456", "12.34"),
        ("-1,239", "-1,23"),
        ("1 250,505", "1 250,50"),
        ("0,001", "0,00"),
    ])
    func dropsDigitsPastTheSecondDecimal(_ text: String, expected: String) {
        #expect(AmountInputLimiter.limit(text) == expected)
    }

    @Test(arguments: ["", "250", "12,", "12,3", "12.34", "-5,5", "1 250,50", "1,2,3", "1.250,50", "1,2a3"])
    func leavesEverythingElseAsIs(_ text: String) {
        #expect(AmountInputLimiter.limit(text) == text)
    }
}

import Foundation
import Testing
@testable import Finwaze

struct LocalOffsetTests {
    @Test(arguments: [
        ("02:00:00", 7200),
        ("-05:30:00", -19800),
        ("+02:00", 7200),
        ("-03:00", -10800),
        ("00:00:00", 0),
    ])
    func parsesIntervals(interval: String, seconds: Int) {
        #expect(LocalOffset(interval: interval)?.seconds == seconds)
    }

    @Test(arguments: ["", "2 hours", "02"])
    func rejectsUnknownFormats(interval: String) {
        #expect(LocalOffset(interval: interval) == nil)
    }

    @Test func formatsIntervalForBackend() {
        #expect(LocalOffset(seconds: 7200).intervalString == "+02:00")
        #expect(LocalOffset(seconds: -19800).intervalString == "-05:30")
        #expect(LocalOffset(seconds: 0).intervalString == "+00:00")
    }

    @Test func currentUsesTimeZoneOffsetAtDate() throws {
        let kyiv = try #require(TimeZone(identifier: "Europe/Kyiv"))
        let summer = Date(timeIntervalSince1970: 1_782_000_000) // June 2026
        let winter = Date(timeIntervalSince1970: 1_767_225_600) // January 2026

        #expect(LocalOffset.current(at: summer, in: kyiv).intervalString == "+03:00")
        #expect(LocalOffset.current(at: winter, in: kyiv).intervalString == "+02:00")
    }
}

struct DateFormattingTests {
    /// 2026-01-31 21:30 UTC — 23:30 on 31 January in Kyiv, already 1 February in Tokyo.
    private let date = Date(timeIntervalSince1970: 1_769_895_000)

    @Test func isoDateUsesGivenTimeZone() throws {
        #expect(date.isoDateString(in: .gmt) == "2026-01-31")
        #expect(date.isoDateString(in: try #require(TimeZone(identifier: "Asia/Tokyo"))) == "2026-02-01")
    }

    @Test func transactionDateUsesStoredOffset() {
        let formatted = date.formattedTransactionDate(offset: LocalOffset(seconds: 7200), locale: Locale(identifier: "en_US"))

        #expect(formatted.contains("Jan 31"))
        #expect(formatted.contains("11:30"))
    }

    @Test func monthFollowsLocale() {
        #expect(date.formattedMonth(locale: Locale(identifier: "en_US"), timeZone: .gmt) == "January 2026")
        #expect(date.formattedMonth(locale: Locale(identifier: "uk_UA"), timeZone: .gmt).contains("2026"))
    }
}

struct MoneyFormattingTests {
    @Test func includesCurrency() {
        let amount = Decimal(string: "1250.5")!

        #expect(amount.formattedAmount(currencyCode: "USD", locale: Locale(identifier: "en_US")) == "$1,250.50")
        let hryvnias = amount.formattedAmount(currencyCode: "UAH", locale: Locale(identifier: "uk_UA"))
        #expect(hryvnias.contains("250,50"))
        #expect(hryvnias.contains("₴") || hryvnias.contains("грн"))
    }

    @Test func keepsDecimalPrecision() {
        let sum = Decimal(string: "0.1")! + Decimal(string: "0.2")!

        #expect(sum == Decimal(string: "0.3")!)
        #expect(sum.formattedAmount(currencyCode: "EUR", locale: Locale(identifier: "en_US")) == "€0.30")
    }
}

struct ExchangeRateFormattingTests {
    private let english = Locale(identifier: "en_US")

    @Test func showsTwoToFourDecimalPlacesByDefault() {
        #expect(Decimal(43).formattedExchangeRate(locale: english) == "43.00")
        #expect(Decimal(string: "43.125")!.formattedExchangeRate(locale: english) == "43.125")
        #expect(Decimal(string: "0.023256")!.formattedExchangeRate(locale: english) == "0.0233")
    }

    @Test func fixedFourDecimalPlaces() {
        #expect(Decimal(43).formattedExchangeRate(fractionLength: 4...4, locale: english) == "43.0000")
    }

    @Test func followsTheInterfaceLanguage() {
        let rate = Decimal(43).formattedExchangeRate(fractionLength: 4...4, locale: Locale(identifier: "uk_UA"))

        #expect(rate == "43,0000")
    }

    @Test func sentenceBetweenCurrencies() {
        #expect(Decimal(43).formattedExchangeRate(from: "EUR", to: "UAH", locale: english) == "1 EUR = 43.00 UAH")
    }
}

import Testing
@testable import Finwaze

struct CredentialsValidatorTests {
    @Test(arguments: [
        ("", CredentialsValidator.EmailIssue.required),
        ("   ", .required),
        ("user", .invalid),
        ("user@mail", .invalid),
        ("us er@mail.com", .invalid),
    ])
    func rejectsBadEmails(email: String, issue: CredentialsValidator.EmailIssue) {
        #expect(CredentialsValidator.validateEmail(email) == issue)
    }

    @Test(arguments: ["user@mail.com", " user@mail.com "])
    func acceptsValidEmails(email: String) {
        #expect(CredentialsValidator.validateEmail(email) == nil)
    }

    @Test func signInPasswordOnlyNeedsToBePresent() {
        #expect(CredentialsValidator.validateSignInPassword("") == .required)
        #expect(CredentialsValidator.validateSignInPassword("1") == nil)
    }

    @Test func newPasswordNeedsMinimumLength() {
        #expect(CredentialsValidator.validateNewPassword("") == .required)
        #expect(CredentialsValidator.validateNewPassword("1234567") == .tooShort)
        #expect(CredentialsValidator.validateNewPassword("12345678") == nil)
    }

    @Test func confirmationMustMatch() {
        #expect(CredentialsValidator.validateConfirmation("", password: "secret12") == .required)
        #expect(CredentialsValidator.validateConfirmation("secret13", password: "secret12") == .mismatch)
        #expect(CredentialsValidator.validateConfirmation("secret12", password: "secret12") == nil)
    }
}

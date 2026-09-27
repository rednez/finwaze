# iOS — Technical Debt

Known gaps in the iOS client that still need to be done. Remove an item once it's done.

## Auth

- **Sign in with Google.** The web client supports it (`src/app/features/auth/login/ui/google-button`).
  On iOS it needs OAuth via `ASWebAuthenticationSession` (`client.auth.signInWithOAuth`), a custom URL
  scheme for the app, and the redirect URL added to `additional_redirect_urls` in `supabase/config.toml`.
- **Sign in with a passkey.** The web client supports it (`passkey-button`, `AuthService.loginWithPasskey`).
  On iOS it needs `AuthenticationServices` (`ASAuthorizationPlatformPublicKeyCredentialProvider`),
  an Associated Domains entitlement (`webcredentials:`) and an `apple-app-site-association` file on the web domain.
- **Set a new password in the app** (`AUTH-09`, `Q-11`). The request screen (`AUTH-08`, `ResetPasswordView`) is
  done: it sends the link and tells the user to come back and sign in with the new password. Still missing: the
  "set a new password" screen opened by the recovery link, including the expired/used-link message with
  "send the link again". Depends on "Email links open the app" below; until then the link opens the web client's
  `/change-password`.
- **Email links open the app and sign the user in** (`AUTH-05`, `AUTH-09`, `Q-11`). The "check your email" screen
  already tells the user to come back and sign in, and can resend the email. Still missing: a confirmation or
  password-reset link that opens the app and signs the user in right away.

  **Chosen approach: `token_hash` links + `verifyOTP`** (the PKCE section of
  https://supabase.com/docs/guides/auth/passwords?queryGroups=language&language=swift&queryGroups=flow&flow=pkce).
  It needs no PKCE `code_verifier`, so it works wherever the email is opened: the same phone, another device or a
  browser. The alternative, `redirectTo` + `client.auth.session(from:)`, only works on the device that started the
  flow, because iOS uses PKCE by default and the verifier stays in that device's Keychain.

  Steps (they touch the web client too; ship them together):
  1. Email templates `supabase/templates/confirm-email.html` and `reset-password.html` (shared with web): replace
     `{{ .ConfirmationURL }}` with a link to our own page, e.g.
     `{{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=email` (`type=recovery` for password reset).
     Mirror the change in the hosted project's templates.
  2. Web: add the `/auth/confirm` route that calls `supabase.auth.verifyOtp({ token_hash, type })`, then goes to
     the dashboard or, for `recovery`, to `/change-password`. Show a clear message and a "send again" action when
     the link is expired or already used (`AUTH-09`).
  3. iOS: Universal Links for `/auth/confirm` — Associated Domains entitlement (`applinks:<web domain>`) and the
     app ID in `apple-app-site-association` on the web domain (the same file passkeys need). Handle the link in
     `.onOpenURL`, call `client.auth.verifyOTP(tokenHash:type:)` in the auth repository, then route by `NAV-07/08`;
     for `recovery`, open the "set a new password" screen (`AUTH-09`). If the app isn't installed, the link falls
     back to the web page from step 2.
  4. Keep the "check your email" screens as they are: they are still needed when the link is opened on another
     device.

  Local development: Universal Links need a real HTTPS domain, so on the simulator test by opening the link with
  `xcrun simctl openurl` or temporarily via a custom URL scheme.

## App

- **Section placeholders.** Every section in `Features/Main/Views/SectionView.swift` except the Wallet and
  Transactions shows "under construction" until its stage lands; the Guide and Settings sheets in `SectionToolbar.swift` wait for stages 15
  and 14.
- **Wallet is partial.** Stages 2 and 5 show the account cards, "New account" and "Transfer money" (`ACC-01`,
  `TRF`). Still missing: account settings on card tap (stage 6) and the Wallet's charts and recent transactions
  (stage 12).
- **Colours are set only on creation.** "New group" / "New category" in the category picker take a palette colour;
  changing or removing the colour of an existing group or category comes with the Groups & categories screen
  (`CAT-10`, stage 7).
- **`WEB_APP_URL` for Staging and Release is empty** (`ios/Config/Staging.xcconfig`, `Release.xcconfig`). Until it
  is set, password-reset emails from those builds link to the Supabase project's `site_url` instead of
  `<web app>/change-password`.

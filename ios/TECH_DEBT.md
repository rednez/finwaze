# iOS — Technical Debt

Known gaps in the iOS client that still need to be done. Remove an item once it's done.

## Auth

- **Sign in with Google.** The web client supports it (`src/app/features/auth/login/ui/google-button`).
  On iOS it needs OAuth via `ASWebAuthenticationSession` (`client.auth.signInWithOAuth`), a custom URL
  scheme for the app, and the redirect URL added to `additional_redirect_urls` in `supabase/config.toml`.
- **Sign in with a passkey.** The web client supports it (`passkey-button`, `AuthService.loginWithPasskey`).
  On iOS it needs `AuthenticationServices` (`ASAuthorizationPlatformPublicKeyCredentialProvider`),
  an Associated Domains entitlement (`webcredentials:`) and an `apple-app-site-association` file on the web domain.
- **Password reset ("Forgot password?").** The web client has the `reset-password` / `change-password` flow.
  iOS needs a reset request screen plus handling of the recovery link, so the user can set a new password in the app
  (`AUTH-08`, `AUTH-09`, `Q-11`; see "Email links open the app" below for how the link works). Until the link
  opens the app, the "check your email" screen must tell the user to come back and sign in with the new password.
- **Demo mode must be read-only** (`AUTH-10`, `Q-08` in `docs/functional-design.md`). By design, demo mode only
  lets the user look around: actions that change data (create, edit, delete) do nothing. The web client has a
  separate data layer for demo mode (`src/app/core/services/demo-mode/`): local demo data, no backend, and every
  write is a no-op. iOS must work the same way: demo implementations of the repository protocols that serve local
  demo data and make every write a no-op, selected when the user taps "Try Demo Mode". No network needed. Today the
  button signs in to the real, shared `demo@mail.com` account, so this must land before any write feature ships —
  otherwise one demo user's changes would alter the demo data for everyone.
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

- **Home screen placeholder.** `Features/Home/Views/HomePlaceholderView.swift` is temporary. Replace it
  with the real main navigation (dashboard, transactions, …).

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

- **Section placeholders.** The Guide and Settings sheets in `SectionToolbar.swift` wait for stages 14 and 15.
- **Deleting an account is not atomic** (`ACC-11`). Like the web, `SupabaseWalletRepository.deleteAccount` first
  deletes the account's balance corrections, then the account. If the second request fails, the corrections are
  already gone and the account stays with a different balance. A single SQL function doing both in one transaction
  would fix it for every client.
- **Changing the currency keeps the corrections' amounts** (`ACC-10`). An account with only balance corrections may
  change its currency; the corrections are not converted, so the same number now reads in the new currency. The web
  behaves the same; ask the product owner whether the balance should be reset or converted.
- **A category with a planned budget cannot be deleted** (`CAT-09`). The screen offers "Delete" for any category
  without transactions, but `monthly_budgets` references categories without `ON DELETE`, so the server refuses when
  a budget exists and the app shows its foreign-key error. Since stage 10 the app creates such budgets itself (the plan
  editor), so this happens more often. The web behaves the same; ask the product owner whether to hide "Delete" in
  that case or delete the budgets together with the category.
- **Completing or cancelling a goal is not atomic** (`GOAL-23`, `GOAL-24`). Like the web, the app first transfers the
  saved money from the goal's account (`make_transfer`), then calls `mark_savings_goal_as_done` /
  `cancel_savings_goal`. If the second request fails, the money is already back on the regular account;
  `GoalClosingViewModel` then retries only the second step. If the user gives up instead, a goal being completed has
  nothing saved any more, so "Mark as done" no longer applies to it. A single SQL function doing both in one
  transaction (e.g. `complete_savings_goal(p_account_id, p_to_account_id)` and the same for cancelling) would fix it
  for every client.
- **`WEB_APP_URL` for Staging and Release is empty** (`ios/Config/Staging.xcconfig`, `Release.xcconfig`). Until it
  is set, password-reset emails from those builds link to the Supabase project's `site_url` instead of
  `<web app>/change-password`.
- **The Dashboard's "this month" is the server's month in UTC** (`DASH-02`, `DASH-04`, `DASH-05`).
  `get_dashboard_totals`, `get_monthly_charged_cash_flow` and `get_current_month_budgets_by_category` take the current
  month from `now()` in the database's time zone (UTC), while the transactions are compared in their local time
  (`GEN-12`). In the first hours of a month east of UTC (or the last hours west of it) the cards still show the previous
  month. The web behaves the same. A fix for every client: an optional `p_local_offset` parameter with a `DEFAULT`
  (backwards compatible), used to pick the month.
- **The Dashboard's budget merges categories with the same name** (`DASH-05`). `get_current_month_budgets_by_category`
  groups by category name, so "Other" in two groups becomes one sector. The web behaves the same; grouping by category
  id (and returning the name) would fix it for every client.

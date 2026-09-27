# Web — Technical Debt

Known gaps in the web client that still need to be done. Remove an item once it's done.

## Guide

- **The Guide promises more than the app does** (`Q-02`, `Q-06` in `docs/functional-design.md`). The Guide must
  describe only what is implemented. Fix these texts in `src/app/core/i18n/guide.translations.ts` in every language
  (`en`, `uk`, `cs`), then carry the corrected texts over to the other clients (`GUIDE-04`):
  - **Groups & categories:** "Finwaze comes with a ready-made set of groups and categories" and the tip "Start with
    the built-in categories". A new account gets only the hidden system group and category; the user creates their
    own groups and categories.
  - **Dashboard:** the summary cards are total balance, income and expenses (not "the difference between them"),
    and there is no "categories you have spent the most on" block — the Budget card shows this month's planned
    budget by category (`DASH-02`, `DASH-05`).
  - **Budget:** there is no progress bar that "fills as you spend" and no warning as you approach the limit — each
    budget shows a donut chart, the amount left and a status badge (`BUD-04`, `BUD-12`).
  - **Wallet:** the tip "When you add an account, set its current balance as the starting point" — the new-account
    form has no balance field; the balance is set afterwards in the account settings (`ACC-07`, `ACC-09`).

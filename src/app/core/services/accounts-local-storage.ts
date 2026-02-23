import { Injectable } from '@angular/core';

const KEY = 'accountsSettings';

@Injectable({
  providedIn: 'root',
})
export class AccountsLocalStorage {
  get hasAccounts(): boolean {
    return this.parsedValue.hasAccounts || false;
  }

  get selectedCurrencyCode(): string | null {
    return this.parsedValue.selectedCurrencyCode || null;
  }

  markAccountsAsPresent(): void {
    localStorage.setItem(
      KEY,
      JSON.stringify({ ...this.parsedValue, hasAccounts: true }),
    );
  }

  setSelectedCurrencyCode(code: string): void {
    localStorage.setItem(
      KEY,
      JSON.stringify({ ...this.parsedValue, selectedCurrencyCode: code }),
    );
  }

  clear(): void {
    localStorage.removeItem(KEY);
  }

  private get parsedValue() {
    const item = localStorage.getItem(KEY);

    if (item) {
      try {
        const parsed = JSON.parse(item);
        return parsed;
      } catch {
        return {};
      }
    } else {
      return {};
    }
  }
}

import { inject } from '@angular/core';
import { CanMatchFn } from '@angular/router';
import { AccountsLocalStorage } from '@core/services/local-storage';

export const hasAccountsGuard: CanMatchFn = async () => {
  const accountsLocalStorage = inject(AccountsLocalStorage);
  return accountsLocalStorage.hasAccounts;
};

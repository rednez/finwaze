import { inject } from '@angular/core';
import { CanMatchFn, Router } from '@angular/router';
import { AccountsLocalStorage } from '@core/services/accounts-local-storage';

export const hasAccountsGuard: CanMatchFn = async (route, state) => {
  const router = inject(Router);

  // TODO: take from the signal store
  const accountsLocalStorage = inject(AccountsLocalStorage);

  // if (await localStorage.hasAccounts()) {
  //   return true;
  // } else {
  //   return new RedirectCommand(router.parseUrl('/setup'));
  // }

  // return localStorage.hasAccounts();
  return accountsLocalStorage.hasAccounts;
};

import { inject, Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { AuthStore } from '@core/store/auth-store';
import { AccountsLocalStorage, UiLocalStorage } from './local-storage';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private readonly authStore = inject(AuthStore);
  private readonly router = inject(Router);
  private readonly accountsLocalStorage = inject(AccountsLocalStorage);
  private readonly uiLocalStorage = inject(UiLocalStorage);

  async loginWithGoogle(): Promise<void> {
    this.authStore.loginWithGoogle();
  }

  async loginWithDemo(): Promise<void> {
    await this.authStore.loginWithDemo();
    this.router.navigate(['dashboard']);
  }

  async logOut(): Promise<void> {
    await this.authStore.logOut();
    this.router.navigate(['login']);
    this.accountsLocalStorage.clear();
    this.uiLocalStorage.clear();
  }
}

import { inject, Injectable, signal } from '@angular/core';
import { Router } from '@angular/router';
import { AuthStore } from '@core/store/auth-store';
import { MessageService } from 'primeng/api';
import { AccountsLocalStorage, UiLocalStorage } from './local-storage';
import { LocalizationService } from './localization.service';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private readonly authStore = inject(AuthStore);
  private readonly router = inject(Router);
  private readonly accountsLocalStorage = inject(AccountsLocalStorage);
  private readonly uiLocalStorage = inject(UiLocalStorage);
  private readonly messageService = inject(MessageService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  readonly isConfirmationEmailSent = signal(false);

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

  async signUp(credits: { email: string; password: string }) {
    const { error } = await this.authStore.signUp(credits);

    if (error) {
      this.messageService.add({
        severity: 'error',
        summary: 'Registration Error',
        detail: error,
      });
    } else {
      this.isConfirmationEmailSent.set(true);
    }
  }

  async loginWithEmail(credits: { email: string; password: string }) {
    const { success, error } = await this.authStore.loginWithEmail(credits);
    if (success) {
      this.router.navigate(['dashboard']);
    } else {
      this.messageService.add({
        severity: 'error',
        summary: 'Login Error',
        detail: error as string,
      });
    }
  }

  async resetPasswordForEmail(email: string) {
    return this.authStore.resetPasswordForEmail(email);
  }

  async updatePassword(password: string, flow: 'reset' | 'update') {
    const { success, error } = await this.authStore.updatePassword(password);
    if (success) {
      if (flow === 'reset') {
        this.router.navigate(['dashboard']);
      } else {
        this.messageService.add({
          severity: 'success',
          summary: 'Password Updated',
          detail: 'Your password has been updated successfully.',
        });
      }
    } else {
      this.messageService.add({
        severity: 'error',
        summary: 'Update Password Error',
        detail: error as string,
      });
    }
  }
}

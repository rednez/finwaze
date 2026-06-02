import { inject, Injectable, signal } from '@angular/core';
import { Router } from '@angular/router';
import { AuthRepository } from '@core/repositories/auth-repository';
import { AuthStore } from '@core/store/auth-store';
import { MessageService } from 'primeng/api';
import { AccountsLocalStorage, UiLocalStorage } from './local-storage';
import { LocalizationService } from './localization.service';
import { Passkey } from './supabase.service';

/**
 * Shared shape of the errors returned by Supabase passkey calls (`AuthError`
 * and `WebAuthnError`); the latter carries a structured `code` we key off of.
 */
interface PasskeyError {
  message: string;
  code?: string;
}

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private readonly authStore = inject(AuthStore);
  private readonly authRepository = inject(AuthRepository);
  private readonly router = inject(Router);
  private readonly accountsLocalStorage = inject(AccountsLocalStorage);
  private readonly uiLocalStorage = inject(UiLocalStorage);
  private readonly messageService = inject(MessageService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  readonly isConfirmationEmailSent = signal(false);

  readonly passkeys = signal<Passkey[]>([]);
  readonly isLoadingPasskeys = signal(false);

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
        life: 5000,
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
        life: 5000,
        severity: 'error',
        summary: 'Login Error',
        detail: error as string,
      });
    }
  }

  async loginWithPasskey() {
    const { success, error } = await this.authStore.loginWithPasskey();
    if (success) {
      this.router.navigate(['dashboard']);
    } else if (!this.isPasskeyCeremonyCancelled(error)) {
      this.messageService.add({
        life: 5000,
        severity: 'error',
        summary: 'Login Error',
        detail: error?.message ?? '',
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
          life: 5000,
          severity: 'success',
          summary: 'Password Updated',
          detail: 'Your password has been updated successfully.',
        });
      }
    } else {
      this.messageService.add({
        life: 5000,
        severity: 'error',
        summary: 'Update Password Error',
        detail: error as string,
      });
    }
  }

  async loadPasskeys() {
    this.isLoadingPasskeys.set(true);
    try {
      const { data, error } = await this.authRepository.listPasskeys();

      if (error) {
        this.showPasskeyError('settings.passkeys.loadError', error.message);
        return;
      }

      this.passkeys.set(data ?? []);
    } catch (error) {
      console.error('Error loading passkeys:', error);
    } finally {
      this.isLoadingPasskeys.set(false);
    }
  }

  async registerPasskey() {
    await this.runPasskeyMutation(
      () => this.authRepository.registerPasskey(),
      'settings.passkeys.addError',
      'settings.passkeys.addSuccess',
    );
  }

  async renamePasskey(passkeyId: string, friendlyName: string) {
    await this.runPasskeyMutation(
      () => this.authRepository.renamePasskey(passkeyId, friendlyName),
      'settings.passkeys.renameError',
      'settings.passkeys.renameSuccess',
    );
  }

  async deletePasskey(passkeyId: string) {
    await this.runPasskeyMutation(
      () => this.authRepository.deletePasskey(passkeyId),
      'settings.passkeys.deleteError',
      'settings.passkeys.deleteSuccess',
    );
  }

  /**
   * Runs a passkey create/rename/delete call, then refreshes the list and
   * reports the outcome. A cancelled WebAuthn ceremony is silently ignored.
   */
  private async runPasskeyMutation(
    action: () => Promise<{ error: PasskeyError | null }>,
    errorKey: string,
    successKey: string,
  ): Promise<void> {
    const { error } = await action();

    if (error) {
      if (!this.isPasskeyCeremonyCancelled(error)) {
        this.showPasskeyError(errorKey, error.message);
      }
      return;
    }

    this.messageService.add({
      life: 5000,
      severity: 'success',
      summary: this.t('settings.passkeys.title'),
      detail: this.t(successKey),
    });

    await this.loadPasskeys();
  }

  // The user can cancel the browser WebAuthn prompt; the SDK surfaces this as a
  // WebAuthnError with this code, which we treat as a no-op rather than a failure.
  private isPasskeyCeremonyCancelled(error: PasskeyError | null): boolean {
    return error?.code === 'ERROR_CEREMONY_ABORTED';
  }

  private showPasskeyError(summaryKey: string, detail: string) {
    this.messageService.add({
      life: 5000,
      severity: 'error',
      summary: this.t(summaryKey),
      detail,
    });
  }
}

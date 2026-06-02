import { DatePipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { AuthService } from '@core/services/auth-service';
import { LocalizationService } from '@core/services/localization.service';
import { Passkey } from '@core/services/supabase.service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ConfirmationService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { RenamePasskeyDialog } from './rename-passkey-dialog';

@Component({
  selector: 'app-passkeys',
  imports: [
    DatePipe,
    ButtonModule,
    ConfirmDialogModule,
    ProgressSpinnerModule,
    RenamePasskeyDialog,
    TranslatePipe,
  ],
  templateUrl: './passkeys.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [ConfirmationService],
})
export class Passkeys {
  private readonly auth = inject(AuthService);
  private readonly confirmationService = inject(ConfirmationService);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly passkeys = this.auth.passkeys;
  protected readonly isLoading = this.auth.isLoadingPasskeys;

  protected readonly renameDialogVisible = signal(false);
  protected readonly passkeyToRename = signal<Passkey | null>(null);

  constructor() {
    void this.auth.loadPasskeys();
  }

  protected addPasskey() {
    void this.auth.registerPasskey();
  }

  protected openRename(passkey: Passkey) {
    this.passkeyToRename.set(passkey);
    this.renameDialogVisible.set(true);
  }

  protected onRenamed(friendlyName: string) {
    const passkey = this.passkeyToRename();
    if (passkey) {
      void this.auth.renamePasskey(passkey.id, friendlyName);
    }
  }

  protected confirmDelete(passkey: Passkey) {
    this.confirmationService.confirm({
      message: this.t('settings.passkeys.deleteConfirm.message'),
      header: this.t('settings.passkeys.deleteConfirm.header'),
      icon: 'pi pi-exclamation-triangle',
      acceptLabel: this.t('settings.passkeys.deleteConfirm.accept'),
      rejectLabel: this.t('settings.passkeys.deleteConfirm.reject'),
      acceptButtonProps: { severity: 'danger' },
      accept: () => void this.auth.deletePasskey(passkey.id),
    });
  }
}

import { Location } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { FormPageLayout } from '@core/layout/form-page-layout';
import { LocalizationService } from '@core/services/localization.service';
import { AuthStore } from '@core/store/auth-store';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { SelectButtonModule } from 'primeng/selectbutton';
import { ToastModule } from 'primeng/toast';
import { Passkeys } from './passkeys';
import { UpdatePassword } from './update-password';

type SettingsSection = 'password' | 'passkeys';

@Component({
  imports: [
    FormPageLayout,
    SelectButtonModule,
    ToastModule,
    FormsModule,
    TranslatePipe,
    UpdatePassword,
    Passkeys,
  ],
  templateUrl: './settings.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class Settings {
  private readonly location = inject(Location);
  private readonly localizationService = inject(LocalizationService);
  private readonly authStore = inject(AuthStore);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly isEmailProvider = computed(
    () => this.authStore.user()?.provider === 'email',
  );

  protected readonly selectedSection = signal<SettingsSection>(
    this.isEmailProvider() ? 'password' : 'passkeys',
  );

  protected readonly sectionOptions = computed(() => {
    const options: { value: SettingsSection; label: string }[] = [];

    if (this.isEmailProvider()) {
      options.push({
        value: 'password',
        label: this.t('settings.sections.password'),
      });
    }

    options.push({
      value: 'passkeys',
      label: this.t('settings.sections.passkeys'),
    });

    return options;
  });

  protected gotoBack() {
    this.location.back();
  }
}

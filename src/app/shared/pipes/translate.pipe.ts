import { inject, Pipe, PipeTransform } from '@angular/core';
import { TRANSLATIONS } from '@core/i18n';
import { LocalizationService } from '@core/services/localization.service';

@Pipe({ name: 'translate', standalone: true, pure: false })
export class TranslatePipe implements PipeTransform {
  private readonly localizationService = inject(LocalizationService);

  transform(key: string): string {
    const lang = this.localizationService.currentLang();
    const parts = key.split('.');
    let value: unknown = TRANSLATIONS[lang];
    for (const part of parts) {
      value = (value as Record<string, unknown>)?.[part];
    }
    return typeof value === 'string' ? value : key;
  }
}

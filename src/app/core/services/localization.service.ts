import { Injectable, signal } from '@angular/core';
import { Lang, TRANSLATIONS } from '@core/i18n';

const STORAGE_KEY = 'app-language';

@Injectable({
  providedIn: 'root',
})
export class LocalizationService {
  readonly currentLang = signal<Lang>((localStorage.getItem(STORAGE_KEY) as Lang) ?? 'en');

  setLanguage(lang: Lang): void {
    localStorage.setItem(STORAGE_KEY, lang);
    this.currentLang.set(lang);
  }

  translate(key: string): string {
    const lang = this.currentLang();
    const parts = key.split('.');
    let value: unknown = TRANSLATIONS[lang];
    for (const part of parts) {
      value = (value as Record<string, unknown>)?.[part];
    }
    return typeof value === 'string' ? value : key;
  }
}

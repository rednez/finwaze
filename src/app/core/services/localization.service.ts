import { Injectable, signal } from '@angular/core';
import { Lang } from '@core/i18n';

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
}

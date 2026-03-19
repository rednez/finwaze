import { computed, effect, inject, Injectable, signal } from '@angular/core';
import { DarkModeHelper } from './dark-mode-helper';

export type Theme = 'light' | 'system' | 'dark';

const STORAGE_KEY = 'app-theme';
const DARK_CLASS = 'dark';
// const DARK_CLASS = 'app-dark';

@Injectable({
  providedIn: 'root',
})
export class ThemeService {
  private readonly darkModeHelper = inject(DarkModeHelper);

  readonly theme = signal<Theme>(this.loadTheme());

  /** Effective dark mode state — combines manual theme choice with OS preference. */
  readonly isDark = computed(() => {
    const theme = this.theme();
    return (
      theme === 'dark' || (theme === 'system' && this.darkModeHelper.isDark())
    );
  });

  constructor() {
    // Reacts to both theme() and isDark() (which tracks OS changes via DarkModeHelper).
    effect(() => {
      const isDark = this.isDark();
      const theme = this.theme();
      document.documentElement.classList.toggle(DARK_CLASS, isDark);
      document.body.style.colorScheme = theme === 'system' ? '' : theme;
    });
  }

  setTheme(theme: Theme): void {
    localStorage.setItem(STORAGE_KEY, theme);
    this.theme.set(theme);
  }

  private loadTheme(): Theme {
    const saved = localStorage.getItem(STORAGE_KEY) as Theme | null;
    return saved ?? 'system';
  }
}

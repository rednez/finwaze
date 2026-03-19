import { Component, inject, input } from '@angular/core';
import { Theme, ThemeService } from '@core/services/theme.service';

const THEME_OPTIONS: { value: Theme; icon: string; label: string }[] = [
  { value: 'light', icon: 'light_mode', label: 'Light' },
  { value: 'system', icon: 'routine', label: 'System' },
  { value: 'dark', icon: 'dark_mode', label: 'Dark' },
];

@Component({
  selector: 'app-theme-switcher',
  imports: [],
  template: `
    <div class="theme-switcher" [class.closed]="closed()">
      <div class="segment" [class.closed]="closed()">
        @for (option of options; track option.value) {
          <button
            [class.active]="theme() === option.value"
            [title]="option.label"
            (click)="setTheme(option.value)"
          >
            <span class="material-symbols-rounded">{{ option.icon }}</span>
          </button>
        }
      </div>
    </div>
  `,
  styles: `
    .theme-switcher {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 12px 8px;
      border-radius: 22px;

      .current-icon {
        flex-shrink: 0;
      }

      &.closed .segment {
        opacity: 0;
        pointer-events: none;
      }
    }

    .segment {
      display: flex;
      gap: 4px;
      background-color: light-dark(var(--p-primary-100), var(--p-surface-700));
      border-radius: 16px;
      padding: 3px;
      transition: opacity 200ms ease-in-out;

      button {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 28px;
        height: 28px;
        border-radius: 13px;
        border: none;
        background: transparent;
        cursor: pointer;
        color: light-dark(var(--p-surface-600), var(--p-surface-300));
        transition:
          background-color 150ms ease-in-out,
          color 150ms ease-in-out;

        .material-symbols-rounded {
          font-size: 18px;
        }

        &:hover:not(.active) {
          background-color: light-dark(
            var(--p-primary-200),
            var(--p-surface-600)
          );
        }

        &.active {
          background-color: var(--p-primary-color);
          color: white;
        }
      }
    }
  `,
})
export class ThemeSwitcher {
  private readonly themeService = inject(ThemeService);

  readonly closed = input(false);

  readonly theme = this.themeService.theme;
  readonly options = THEME_OPTIONS;

  setTheme(theme: Theme): void {
    this.themeService.setTheme(theme);
  }
}

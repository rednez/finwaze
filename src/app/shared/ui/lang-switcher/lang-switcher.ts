import { Component, computed, inject } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Lang } from '@core/i18n';
import { LocalizationService } from '@core/services/localization.service';
import { SelectModule } from 'primeng/select';

interface LangOption {
  code: Lang;
  label: string;
  flag: string;
}

const LANG_OPTIONS: LangOption[] = [
  { code: 'en', label: 'English', flag: '🇺🇸' },
  { code: 'uk', label: 'Українська', flag: '🇺🇦' },
  { code: 'cs', label: 'Čeština', flag: '🇨🇿' },
];

@Component({
  selector: 'app-lang-switcher',
  imports: [SelectModule, FormsModule],
  template: `
    <p-select
      [options]="options"
      [ngModel]="selectedLang()"
      (ngModelChange)="setLang($event.code)"
      appendTo="body"
      [pt]="{
        root: {
          class: 'border-none! bg-transparent! shadow-none! ring-0! min-w-0!',
        },
        label: { class: 'p-0! py-1! flex items-center' },
        dropdown: {
          class: 'w-5! p-0! flex items-center text-gray-400 dark:text-gray-500',
        },
      }"
    >
      <ng-template #selectedItem let-selected>
        <span class="text-lg leading-none select-none mr-2">
          {{ selected.flag }}
        </span>
      </ng-template>
      <ng-template let-option #item>
        <div class="flex items-center gap-3">
          <span class="text-lg leading-none select-none">
            {{ option.flag }}
          </span>
          <span class="text-sm">{{ option.label }}</span>
        </div>
      </ng-template>
    </p-select>
  `,
})
export class LangSwitcher {
  private readonly localizationService = inject(LocalizationService);

  protected readonly options = LANG_OPTIONS;

  protected readonly selectedLang = computed(
    () =>
      LANG_OPTIONS.find(
        (o) => o.code === this.localizationService.currentLang(),
      ) ?? LANG_OPTIONS[0],
  );

  protected setLang(code: Lang): void {
    this.localizationService.setLanguage(code);
  }
}

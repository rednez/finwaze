import { Component, input, model, viewChild } from '@angular/core';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ResponsiveOverlay } from '@shared/ui/responsive-overlay';

@Component({
  selector: 'app-currency-picker',
  imports: [ResponsiveOverlay, TranslatePipe],
  template: `
    <button
      type="button"
      class="flex shrink-0 items-center gap-1.5 rounded-xl bg-gray-100 px-2.5 py-1.5 text-xs font-semibold transition-colors hover:bg-gray-200 disabled:opacity-50 dark:bg-gray-800 dark:hover:bg-gray-700"
      [disabled]="disabled()"
      [attr.aria-expanded]="overlay.isOpen()"
      [attr.aria-label]="'shared.currency' | translate"
      aria-haspopup="listbox"
      (click)="overlay.toggle($event)"
    >
      {{ currencyCode() || '—' }}
      <i class="pi pi-chevron-down text-[0.625rem] text-muted-color"></i>
    </button>

    <app-responsive-overlay #overlay [header]="'shared.currency' | translate">
      <div class="max-h-72 w-full overflow-y-auto sm:w-44" role="listbox">
        @for (code of currencies(); track code) {
          <button
            type="button"
            role="option"
            class="flex w-full items-center justify-between rounded-xl px-3 py-2.5 text-start text-sm transition-colors hover:bg-emphasis"
            [class.bg-highlight]="code === currencyCode()"
            [class.font-semibold]="code === currencyCode()"
            [attr.aria-selected]="code === currencyCode()"
            (click)="select(code)"
          >
            {{ code }}
            @if (code === currencyCode()) {
              <i class="pi pi-check text-xs"></i>
            }
          </button>
        }
      </div>
    </app-responsive-overlay>
  `,
  host: { class: 'contents' },
})
export class CurrencyPicker {
  readonly currencies = input<string[]>([]);
  readonly disabled = input(false);
  readonly currencyCode = model<string | null>(null);

  private readonly overlay = viewChild.required(ResponsiveOverlay);

  protected select(code: string) {
    this.currencyCode.set(code);
    this.overlay().close();
  }
}

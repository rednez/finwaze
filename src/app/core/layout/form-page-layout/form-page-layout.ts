import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-form-page-layout',
  imports: [ButtonModule],
  template: `
    <div class="absolute top-2 left-3">
      <p-button
        icon="pi pi-arrow-left"
        [rounded]="true"
        [text]="true"
        size="large"
        (onClick)="back.emit()"
      />
    </div>

    <div class="mb-4">
      <h4 class="text-lg font-semibold">{{ header() }}</h4>
      @if (subheader()) {
        <div class="text-sm text-muted-color">
          {{ subheader() }}
        </div>
      }
    </div>

    <ng-content />
  `,
  styles: `
    @reference 'tailwindcss';

    :host {
      @apply block text-center md:mx-auto w-full max-w-160 p-5 
        sm:bg-white/40 sm:dark:bg-zinc-900/40 backdrop-blur-2xl 
        sm:border sm:border-gray-50 sm:dark:border-zinc-800/50 
        rounded-[40px] sm:shadow-2xl sm:shadow-violet-500/16
        sm:dark:shadow-none;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FormPageLayout {
  readonly header = input<string>();
  readonly subheader = input<string>();
  readonly back = output<void>();
}

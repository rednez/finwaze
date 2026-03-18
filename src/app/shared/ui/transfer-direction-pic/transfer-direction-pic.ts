import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-transfer-direction-pic',
  template: `
    <span class="material-symbols-rounded text-gray-600 dark:text-gray-400">
      arrow_downward_alt
    </span>
  `,
  styles: `
    @reference 'tailwindcss';

    :host {
      @apply flex shrink-0 bg-gray-200 dark:bg-gray-800 size-8 rounded-full 
        items-center justify-center;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TransferDirectionPic {}

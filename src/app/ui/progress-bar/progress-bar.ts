import {
  ChangeDetectionStrategy,
  Component,
  input,
  ViewEncapsulation,
} from '@angular/core';
import { ProgressBarDesignTokens } from '@primeuix/themes/types/progressbar';
import { ProgressBarModule } from 'primeng/progressbar';

@Component({
  selector: 'app-progress-bar',
  imports: [ProgressBarModule],
  template: ` <p-progressbar [value]="value()" [dt]="progressSchema" /> `,
  styles: `
    .p-progressbar-value {
      border-radius: 20px;
    }
  `,
  encapsulation: ViewEncapsulation.None,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ProgressBar {
  readonly value = input(0);

  protected readonly progressSchema: ProgressBarDesignTokens = {
    root: {
      height: '27px',
      borderRadius: '12px',
    },
    colorScheme: {
      light: {
        root: {
          background: 'var(--p-primary-100)',
        },
      },
      dark: {
        root: {
          background: 'var(--p-surface-800)',
        },
      },
    },
  };
}

import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-filled-block',
  imports: [],
  template: ` <ng-content /> `,
  styles: `
    :host {
      display: block;
      border-radius: 24px;
      border: 1px solid light-dark(#e1e8f1, var(--p-surface-800));
      background: light-dark(#faf9ff, var(--p-surface-900));
      padding: 32px 16px;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FilledBlock {}

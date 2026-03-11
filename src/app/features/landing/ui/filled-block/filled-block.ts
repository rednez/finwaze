import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-filled-block',
  imports: [],
  template: ` <ng-content /> `,
  styles: `
    :host {
      display: block;
      border-radius: 28px;
      border: 1px solid
        light-dark(rgba(148, 57, 254, 0.08), rgba(255, 255, 255, 0.06));
      background: light-dark(#ffffff, var(--p-surface-900));
      box-shadow: 0 8px 40px
        light-dark(rgba(94, 35, 233, 0.07), rgba(0, 0, 0, 0.3));
      padding: 52px 40px;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FilledBlock {}

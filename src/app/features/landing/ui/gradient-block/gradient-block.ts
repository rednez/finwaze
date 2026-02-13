import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-gradient-block',
  imports: [],
  template: ` <ng-content /> `,
  styles: `
    :host {
      display: block;
      padding: 32px;
      border-radius: 24px;
      color: #fff;
      background: linear-gradient(90deg, #5e23e9 0%, #ca27f3 100%), #faf9ff;
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GradientBlock {}

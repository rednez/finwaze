import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-card-header-title',
  imports: [],
  template: ` <ng-content /> `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'font-display text-lg font-semibold',
  },
})
export class CardHeaderTitle {}

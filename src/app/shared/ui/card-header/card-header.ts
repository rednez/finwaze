import { ChangeDetectionStrategy, Component } from '@angular/core';

@Component({
  selector: 'app-card-header',
  imports: [],
  template: ` <ng-content /> `,
  host: {
    class: 'block mb-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CardHeader {}

import { Component } from '@angular/core';

@Component({
  selector: 'app-card-header-title',
  imports: [],
  template: ` <ng-content /> `,
  host: {
    class: 'font-display text-lg font-semibold',
  },
})
export class CardHeaderTitle {}

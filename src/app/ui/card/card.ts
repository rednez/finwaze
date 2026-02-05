import { Component } from '@angular/core';

@Component({
  selector: 'app-card',
  imports: [],
  template: `
    <ng-content select="app-card-header" />
    <ng-content />
  `,
  styles: ``,
  host: {
    class:
      'block border border-surface-200 dark:border-surface-600 rounded-3xl p-4',
  },
})
export class Card {}

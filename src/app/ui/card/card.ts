import { Component } from '@angular/core';

@Component({
  selector: 'app-card',
  imports: [],
  template: `<ng-content />`,
  host: {
    class: 'block border border-gray-200 dark:border-gray-600 rounded-3xl p-4',
  },
})
export class Card {}

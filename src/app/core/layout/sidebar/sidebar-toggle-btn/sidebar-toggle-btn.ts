import { Component, input } from '@angular/core';

@Component({
  selector: 'app-sidebar-toggle-btn',
  imports: [],
  template: `
    <div
      class="flex items-center justify-center size-6 rounded-full cursor-pointer border text-primary-300 dark:text-primary-700 transition-transform duration-200 ease-in"
      [class.rotate]="closed()"
    >
      <span class="pi pi-angle-left text-gray-800 dark:text-gray-300"></span>
    </div>
  `,
  styles: `
    .rotate {
      rotate: 180deg;
    }
  `,
  host: {
    class: 'hidden sm:block',
    '[class.rotate]': 'closed()',
  },
})
export class SidebarToggleBtn {
  closed = input(false);
}

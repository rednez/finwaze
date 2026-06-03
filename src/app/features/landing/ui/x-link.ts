import { Component } from '@angular/core';

@Component({
  selector: 'app-x-link',
  template: `
    <a
      href="https://x.com/finwazeapp"
      target="_blank"
      rel="noopener noreferrer"
      aria-label="X"
      class="hover:text-violet-500 dark:hover:text-violet-400 transition-colors duration-200"
    >
      <svg
        fill="currentColor"
        role="img"
        width="16"
        height="16"
        viewBox="0 0 24 24"
        xmlns="http://www.w3.org/2000/svg"
      >
        <title>X</title>
        <path
          d="M14.234 10.162 22.977 0h-2.072l-7.591 8.824L7.251 0H.258l9.168 13.343L.258 24H2.33l8.016-9.318L16.749 24h6.993zm-2.837 3.299-.929-1.329L3.076 1.56h3.182l5.965 8.532.929 1.329 7.754 11.09h-3.182z"
        />
      </svg>
    </a>
  `,
  styles: `
    :host {
      display: block;
      height: 16px;
      width: 16px;
    }
  `,
})
export class XLink {}

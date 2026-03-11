import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-description-section',
  imports: [],
  template: `
    <div class="self-center mb-2">
      <ng-content />
    </div>
    <h3
      class="font-bold text-lg tracking-tight text-gray-800 dark:text-gray-100 mt-5 mb-4"
    >
      {{ title() }}
    </h3>
    <ul class="space-y-2.5">
      @for (bullet of bullets(); track bullet) {
        <li
          class="flex items-center gap-2.5 text-sm text-gray-600 dark:text-surface-300"
        >
          <span class="w-1.5 h-1.5 rounded-full bg-violet-600 shrink-0"></span>
          {{ bullet }}
        </li>
      }
    </ul>
  `,
  host: {
    class: 'flex flex-col flex-1',
  },
  styles: `
    :host {
      padding: 28px;
      border-radius: 24px;
      background: light-dark(#ffffff, var(--p-surface-800));
      border: 1px solid light-dark(#f0f0f6, rgba(255, 255, 255, 0.05));
      box-shadow: 0 4px 24px
        light-dark(rgba(94, 35, 233, 0.06), rgba(0, 0, 0, 0.18));
      transition:
        box-shadow 0.25s ease,
        transform 0.25s ease;
    }

    :host:hover {
      box-shadow: 0 8px 36px
        light-dark(rgba(94, 35, 233, 0.1), rgba(0, 0, 0, 0.26));
      transform: translateY(-2px);
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DescriptionSection {
  readonly title = input('');
  readonly bullets = input<string[]>([]);
}

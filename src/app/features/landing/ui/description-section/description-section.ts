import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-description-section',
  imports: [],
  template: `
    <div class="self-center">
      <ng-content />
    </div>
    <div class="font-bold text-lg text-gray-800 dark:text-gray-200 mt-5 mb-4">
      {{ title() }}
    </div>
    <ul class="list-disc list-inside">
      @for (bullet of bullets(); track bullet) {
        <li class="dark:text-surface-300">{{ bullet }}</li>
      }
    </ul>
  `,
  host: {
    class: 'flex flex-col',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DescriptionSection {
  readonly title = input('');
  readonly bullets = input<string[]>([]);
}

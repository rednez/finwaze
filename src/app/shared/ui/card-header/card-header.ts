import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { ProgressSpinnerModule } from 'primeng/progressspinner';

@Component({
  selector: 'app-card-header',
  imports: [ProgressSpinnerModule],
  template: `
    <div class="flex items-center gap-4">
      <ng-content select="app-card-header-title" />

      @if (isLoading()) {
        <div>
          <p-progress-spinner
            ariaLabel="loading"
            strokeWidth="7"
            class="size-5!"
          />
        </div>
      }
    </div>

    <ng-content select="[append-right]" />
  `,
  host: {
    class: 'flex justify-between gap-4 mb-4',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CardHeader {
  readonly isLoading = input(false);
}

import { PercentPipe } from '@angular/common';
import { Component, computed, input } from '@angular/core';
import { Card } from '@ui/card';
import { StyledAmount } from '@ui/styled-amount';
import { CardModule } from 'primeng/card';
import { TagModule } from 'primeng/tag';

@Component({
  selector: 'app-amount-widget',
  imports: [Card, StyledAmount, CardModule, TagModule, PercentPipe],
  template: `
    <app-card>
      <div class="text-lg font-medium mb-4">{{ title() }}</div>
      <app-styled-amount currency="$" [amount]="amount()" />
      <div class="mt-2">
        <p-tag
          [icon]="percentIcon()"
          [severity]="percentColor()"
          [rounded]="true"
          [value]="(percent() / 100 | percent)!"
        />
        <span class="ml-1 text-gray-400 text-sm">vs last month</span>
      </div>
    </app-card>
  `,
})
export class AmountWidget {
  readonly title = input.required<string>();
  readonly amount = input.required<number>();
  readonly percent = input.required<number>();
  readonly isPositive = input(true);
  readonly isGrowth = input(true);

  readonly percentColor = computed(() =>
    this.isPositive() ? 'success' : 'danger',
  );
  readonly percentIcon = computed(() =>
    this.isGrowth() ? 'pi pi-arrow-up' : 'pi pi-arrow-down',
  );
}

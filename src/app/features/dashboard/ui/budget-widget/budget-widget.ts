import {
  ChangeDetectionStrategy,
  Component,
  computed,
  signal,
} from '@angular/core';
import { Card } from '@shared/ui/card';
import { DonutSummaryChart } from '@shared/ui/donut-summary-chart';
import { generateAnalogColors } from '@core/utils/colors';
import { v4 } from 'uuid';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';

@Component({
  selector: 'app-budget-widget',
  imports: [Card, DonutSummaryChart, CardHeader, CardHeaderTitle],
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>Budget</app-card-header-title>
      </app-card-header>

      <div class="flex gap-2 items-center">
        <div>
          @for (cat of displayedCategories(); track cat.id) {
            <div class="flex gap-2 items-center">
              <span
                class="block rounded-full size-2"
                [style]="{ backgroundColor: cat.color }"
              ></span>
              <span class="text-sm/6">{{ cat.name }}</span>
            </div>
          }
        </div>

        <app-donut-summary-chart
          title="Total for month"
          [currency]="currency()"
          [items]="displayedCategories()"
        />
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetWidget {
  readonly categories = signal([
    {
      name: 'Taxes',
      amount: 500,
    },
    {
      name: 'Life',
      amount: 900,
    },
    {
      name: 'Medicine',
      amount: 100,
    },
    {
      name: 'Foods',
      amount: 2400,
    },
    {
      name: 'Credits',
      amount: 1200,
    },
    {
      name: 'Car',
      amount: 1000,
    },
    {
      name: 'Stuff',
      amount: 500,
    },
    {
      name: 'Other',
      amount: 750,
    },
    {
      name: 'Other2',
      amount: 790,
    },
  ]);

  readonly currency = signal('USD');

  protected readonly displayedCategories = computed(() => {
    const colors = generateAnalogColors(this.categories().length);

    const sortedCategories = this.categories()
      .sort((a, b) => b.amount - a.amount)
      .map((cat, index) => ({
        ...cat,
        id: v4(),
        color: colors[index],
      }));

    return this.categories().length <= 7
      ? sortedCategories
      : [
          ...sortedCategories.slice(0, 6),
          {
            id: v4(),
            name: 'Rest categories',
            amount: sortedCategories
              .slice(6)
              .reduce((sum, cat) => sum + cat.amount, 0),
            color: '#e2e1e3',
          },
        ];
  });
}

import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { Card } from '@ui/card';
import { BudgetChart } from '../budget-chart/budget-chart';

@Component({
  selector: 'app-budget-widget',
  imports: [Card, BudgetChart],
  template: `
    <app-card>
      <div class="text-lg font-medium mb-4">Budget</div>
      <div class="flex gap-2 items-center">
        <div>
          @for (cat of categories(); track cat.id) {
            <div class="flex gap-2 items-center">
              <span class="block rounded-full {{ cat.color }} size-2"></span>
              <span class="text-sm/6">{{ cat.name }}</span>
            </div>
          }
        </div>

        <app-budget-chart [currency]="currency()" [categories]="categories()" />
      </div>
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetWidget {
  readonly categories = signal([
    {
      id: 1,
      name: 'Foods',
      color: 'bg-primary',
      chartColor: '--p-primary-color',
      amount: 2400,
    },
    {
      id: 2,
      name: 'Life',
      color: 'bg-primary-300',
      chartColor: '--p-primary-300',
      amount: 900,
    },
    {
      id: 3,
      name: 'Medicine',
      color: 'bg-primary-200',
      chartColor: '--p-primary-200',
      amount: 100,
    },
    {
      id: 4,
      name: 'Credits',
      color: 'bg-gray-500',
      chartColor: '--p-gray-500',
      amount: 1200,
    },
    {
      id: 5,
      name: 'Taxes',
      color: 'bg-gray-300',
      chartColor: '--p-gray-300',
      amount: 500,
    },
    {
      id: 6,
      name: 'Car',
      color: 'bg-gray-200',
      chartColor: '--p-gray-200',
      amount: 1000,
    },
    {
      id: 7,
      name: 'Other',
      color: 'bg-gray-100',
      chartColor: '--p-gray-100',
      amount: 750,
    },
  ]);
  readonly currency = signal('$');
}

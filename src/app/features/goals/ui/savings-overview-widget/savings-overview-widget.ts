import {
  ChangeDetectionStrategy,
  Component,
  effect,
  inject,
  linkedSignal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { SavingsOverviewStore } from '../../stores/savings-overview-store';
import { SavingsOverviewChart } from '../savings-overview-chart/savings-overview-chart';

@Component({
  selector: 'app-savings-overview-widget',
  imports: [
    Card,
    SavingsOverviewChart,
    FormsModule,
    SelectModule,
    IftaLabelModule,
    CardHeaderTitle,
    CardHeader,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Savings overview</app-card-header-title>

        <p-select
          append-right
          [(ngModel)]="currency"
          [options]="store.availableCurrencies()"
          optionLabel="name"
          size="small"
          [dt]="{
            root: {
              borderRadius: '12px',
            },
          }"
        />
      </app-card-header>

      <app-savings-overview-chart
        [labels]="store.labels()"
        [currentSavings]="store.currentSavings()"
        [previousSavings]="store.previousSavings()"
      />
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SavingsOverviewWidget {
  protected readonly store = inject(SavingsOverviewStore);

  protected currency = linkedSignal<{ name: string }[], { name: string }>({
    source: this.store.availableCurrencies,
    computation: (newAvailableCurrencies, previous) =>
      newAvailableCurrencies.find((c) => c.name === previous?.value?.name) ??
      newAvailableCurrencies[0],
  });

  constructor() {
    effect(() => {
      const currency = this.currency();
      if (currency) {
        this.store.updateCurrencyCode(currency.name);
      }
    });
  }
}

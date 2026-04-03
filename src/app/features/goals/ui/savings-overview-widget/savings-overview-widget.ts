import {
  ChangeDetectionStrategy,
  Component,
  effect,
  inject,
  model,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DatePickerModule } from 'primeng/datepicker';
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
    DatePickerModule,
    CardHeaderTitle,
    CardHeader,
  ],
  template: `
    <app-card>
      <app-card-header class="flex items-center justify-between">
        <app-card-header-title>Savings overview</app-card-header-title>

        <div append-right class="flex gap-2">
          <p-datepicker
            [(ngModel)]="date"
            view="year"
            dateFormat="yy"
            [readonlyInput]="true"
            size="small"
            [inputStyle]="{
              borderRadius: '12px',
            }"
          />

          <p-select
            [(ngModel)]="currency"
            [options]="currencies()"
            optionLabel="name"
            size="small"
            [dt]="{
              root: {
                borderRadius: '12px',
              },
            }"
          />
        </div>
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

  protected readonly currencies = signal([
    { name: 'USD' },
    { name: 'EUR' },
    { name: 'UAH' },
  ]);

  protected date = model(new Date());
  protected currency = model({ name: this.store.selectedCurrencyCode() });

  constructor() {
    effect(() => {
      this.store.updateYear(this.date());
    });

    effect(() => {
      const c = this.currency();
      if (c) {
        this.store.updateCurrencyCode(c.name);
      }
    });
  }
}

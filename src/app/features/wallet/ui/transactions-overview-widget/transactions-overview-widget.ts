import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  input,
  linkedSignal,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@shared/ui/card';
import { DatePickerModule } from 'primeng/datepicker';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { ToggleButtonModule } from 'primeng/togglebutton';
import { TooltipModule } from 'primeng/tooltip';
import { TransactionCashFlowItem } from '../../models';
import { TransactionsOverviewChart } from '../transactions-overview-chart';

@Component({
  selector: 'app-transactions-overview-widget',
  imports: [
    CommonModule,
    Card,
    TransactionsOverviewChart,
    FormsModule,
    TableModule,
    SelectModule,
    DatePickerModule,
    TooltipModule,
    ToggleButtonModule,
  ],
  template: `
    <app-card>
      <div class="flex flex-col xl:flex-row xl:justify-between gap-3 mb-4">
        <div class="flex items-center gap-2">
          <div>Daily Transaction Flow</div>
          <span class="material-symbols-rounded" [pTooltip]="tooltipContent">
            info
          </span>
          <ng-template #tooltipContent>
            <div class="text-sm">
              The expenses and incomes of the selected currency are based on the
              transaction amounts for each day of the selected month.
            </div>
          </ng-template>
        </div>

        <div class="flex gap-2">
          <p-togglebutton
            [ngModel]="includeIncomes()"
            (ngModelChange)="incomesToggled.emit($event)"
            onLabel="Incomes On"
            offLabel="Incomes Off"
            class="w-29"
            size="small"
          />

          <p-datepicker
            [ngModel]="month()"
            (ngModelChange)="monthChanged.emit($event)"
            dateFormat="mm/yy"
            [readonlyInput]="true"
            size="small"
            view="month"
            class="w-21"
            [inputStyle]="{
              borderRadius: '12px',
            }"
          />

          <p-select
            [ngModel]="currency()"
            (ngModelChange)="currencyChanged.emit($event)"
            [options]="currenciesOptions()"
            optionLabel="name"
            optionValue="name"
            size="small"
            [dt]="{
              root: {
                borderRadius: '12px',
              },
            }"
          />
        </div>
      </div>

      <app-transactions-overview-chart
        [labels]="labels()"
        [incomes]="incomes()"
        [expenses]="expenses()"
        [hasIncludeIncome]="includeIncomes()"
      />
    </app-card>
  `,
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TransactionsOverviewWidget {
  readonly currencies = input<string[]>([]);
  readonly initialIncomesToggle = input(true);
  readonly initialCurrency = input<string>();
  readonly initialMonth = input(new Date());
  readonly data = input<TransactionCashFlowItem[]>([]);
  readonly incomesToggled = output<boolean>();
  readonly monthChanged = output<Date>();
  readonly currencyChanged = output<string>();

  protected readonly includeIncomes = linkedSignal(() =>
    this.initialIncomesToggle(),
  );
  protected readonly month = linkedSignal(() => this.initialMonth());
  protected readonly currency = linkedSignal(() => this.initialCurrency());

  protected readonly currenciesOptions = computed(() =>
    this.currencies().map((c) => ({ name: c })),
  );

  protected readonly labels = computed(() => this.data().map((d) => d.label));
  protected readonly incomes = computed(() => this.data().map((d) => d.income));
  protected readonly expenses = computed(() =>
    this.data().map((d) => d.expense),
  );
}

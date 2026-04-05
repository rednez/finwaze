import { CurrencyPipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  input,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { InputNumberModule } from 'primeng/inputnumber';
import { TooltipModule } from 'primeng/tooltip';
import { BudgetCategoryRow } from '../../models';

@Component({
  selector: 'app-create-budget-category-row',
  imports: [
    CurrencyPipe,
    FormsModule,
    ButtonModule,
    InputNumberModule,
    TooltipModule,
  ],
  template: `
    <div
      class="relative grid grid-cols-[1fr_repeat(4,minmax(110px,130px))_40px] gap-2 items-center px-4 py-2.5"
    >
      <span
        class="text-sm text-surface-700 dark:text-surface-300 truncate pl-4"
      >
        {{ categoryName() }}
      </span>

      <div
        class="flex justify-end"
        [pTooltip]="invalid() ? 'Amount must be greater than 0' : ''"
        tooltipPosition="top"
      >
        <p-inputNumber
          [ngModel]="category().plannedAmount"
          (ngModelChange)="plannedChange.emit($event)"
          [minFractionDigits]="0"
          [maxFractionDigits]="2"
          [min]="0"
          [invalid]="invalid()"
          inputStyleClass="text-right text-sm w-28 h-8"
          [showButtons]="false"
        />
      </div>

      <span class="text-right text-sm text-surface-500">
        {{
          category().prevPlannedAmount
            | currency: currencyCode() : 'symbol' : '1.0-0'
        }}
      </span>

      <span
        class="text-right text-sm font-medium"
        [class.text-surface-700]="
          category().currentSpentAmount <= category().plannedAmount
        "
        [class.dark:text-surface-200]="
          category().currentSpentAmount <= category().plannedAmount
        "
      >
        {{
          category().currentSpentAmount
            | currency: currencyCode() : 'symbol' : '1.0-0'
        }}
      </span>

      <span class="text-right text-sm text-surface-500">
        {{
          category().prevSpentAmount
            | currency: currencyCode() : 'symbol' : '1.0-0'
        }}
      </span>

      <div class="flex justify-end">
        <p-button
          icon="pi pi-times"
          severity="danger"
          variant="text"
          size="small"
          [rounded]="true"
          pTooltip="Видалити категорію"
          tooltipPosition="left"
          (onClick)="remove.emit()"
        />
      </div>
    </div>
  `,
  host: {
    class:
      'relative block rounded-lg overflow-hidden bg-surface-50 dark:bg-surface-900',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CreateBudgetCategoryRow {
  readonly category = input.required<BudgetCategoryRow>();
  readonly categoryName = input.required<string>();
  readonly currencyCode = input('');
  readonly invalid = input(false);

  readonly plannedChange = output<number | null>();
  readonly remove = output();
}

import { CommonModule } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  input,
  linkedSignal,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { TransactionType } from '@core/models/transactions';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { FloatLabelModule } from 'primeng/floatlabel';
import { SelectModule } from 'primeng/select';

@Component({
  selector: 'app-groups-filters',
  imports: [CommonModule, FormsModule, SelectModule, FloatLabelModule],
  templateUrl: './groups-filters.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GroupsFilters {
  readonly initTransactionType = input<string | null>();
  readonly transactionTypeChanged = output<TransactionType | null>();

  protected readonly transactionTypesOptions = [
    { value: 'all', name: 'All' },
    { value: 'income', name: 'Income' },
    { value: 'expense', name: 'Expense' },
  ];

  protected readonly selectInputSchema: SelectDesignTokens = {
    root: {
      borderRadius: '12px',
    },
  };

  protected selectedTransactionType = linkedSignal(
    () => this.initTransactionType() || 'all',
  );

  protected onTransactionTypeChange(event: string) {
    this.selectedTransactionType.set(event);
    this.transactionTypeChanged.emit(
      event !== 'all' ? (event as TransactionType) : null,
    );
  }
}

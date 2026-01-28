import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DatePickerDesignTokens } from '@primeuix/themes/types/datepicker';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { AppStore } from '@store/app-store';
import {
  TransactionDataTableColumnType,
  TransactionsDataTable,
} from '@ui/transactions-data-table';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';

@Component({
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [
    FormsModule,
    TableModule,
    TransactionsDataTable,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
  ],
  templateUrl: './transactions.html',
  styleUrls: ['./transactions.css'],
})
export class Transactions {
  protected readonly store = inject(AppStore);

  protected readonly tableCols: TransactionDataTableColumnType[] = [
    'date',
    'group',
    'category',
    'transactionAmount',
    'chargedAmount',
    'exchangeRate',
    'description',
  ];

  protected readonly currencies = signal([
    { name: 'USD' },
    { name: 'EUR' },
    { name: 'UAH' },
  ]);

  protected readonly groups = signal([
    { name: 'Life' },
    { name: 'Sport' },
    { name: 'Medical' },
  ]);

  protected readonly categories = signal([
    { name: 'Food' },
    { name: 'Car wash' },
    { name: 'Hockey' },
    { name: 'Football' },
    { name: 'Mathematic' },
  ]);

  protected date = new Date();
  protected currency: { name: string } = { name: 'USD' };
  protected group: { name: string } = { name: 'Life' };
  protected category: { name: string } = { name: 'Food' };

  protected readonly selectInputSchema: SelectDesignTokens = {
    root: {
      borderRadius: '22px',
    },
  };
}

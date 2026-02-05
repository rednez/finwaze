import { ChangeDetectionStrategy, Component, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';

@Component({
  selector: 'app-transactions-filters',
  imports: [
    FormsModule,
    TableModule,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
  ],
  templateUrl: './transactions-filters.html',
  host: {
    class: 'flex gap-2 mb-4 flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TransactionsFilters {
  protected readonly currencies = signal([
    { name: 'All' },
    { name: 'USD' },
    { name: 'EUR' },
    { name: 'UAH' },
  ]);

  protected readonly groups = signal([
    { name: 'All' },
    { name: 'Life' },
    { name: 'Sport' },
    { name: 'Medical' },
  ]);

  protected readonly categories = signal([
    { name: 'All' },
    { name: 'Food' },
    { name: 'Car wash' },
    { name: 'Hockey' },
    { name: 'Football' },
    { name: 'Mathematic' },
  ]);

  protected readonly selectInputSchema: SelectDesignTokens = {
    root: {
      borderRadius: '16px',
    },
  };

  protected date = new Date();
  protected currency?: { name: string } = { name: 'All' };
  protected group: { name: string } = { name: 'All' };
  protected category: { name: string } = { name: 'All' };
}

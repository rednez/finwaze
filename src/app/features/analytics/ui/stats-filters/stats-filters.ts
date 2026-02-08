import {
  ChangeDetectionStrategy,
  Component,
  model,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { MultiSelectModule } from 'primeng/multiselect';

// TODO: ???
interface Account {
  id: number;
  name: string;
}

@Component({
  selector: 'app-stats-filters',
  imports: [
    FormsModule,
    TableModule,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
    MultiSelectModule,
  ],
  templateUrl: './stats-filters.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: {
    class: 'flex gap-2 flex-wrap',
  },
})
export class StatsFilters {
  protected readonly currencies = signal([
    { name: 'USD' },
    { name: 'UAH' },
    { name: 'EUR' },
    { name: 'CZK' },
  ]);

  protected readonly accounts = signal<Account[]>([
    { name: 'Account 1', id: 1 },
    { name: 'Account 2', id: 2 },
  ]);

  protected month = model(new Date());
  protected currency: { name: string } = model({ name: 'USD' });
  protected selectedAccount = model<Account[]>([]);
}

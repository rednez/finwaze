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

interface Group {
  id: number;
  name: string;
}

@Component({
  selector: 'app-budget-filters',
  imports: [
    FormsModule,
    TableModule,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
    MultiSelectModule,
  ],
  templateUrl: './budget-filters.html',
  host: {
    class: 'flex flex-col gap-2',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetFilters {
  protected readonly currencies = signal([
    { name: 'USD' },
    { name: 'UAH' },
    { name: 'EUR' },
    { name: 'CZK' },
  ]);

  protected readonly statuses = signal([
    { name: 'All' },
    { name: 'On track' },
    { name: 'Attention' },
    { name: 'Over budget' },
  ]);

  protected readonly groups = signal<Group[]>([
    { name: 'Life', id: 1 },
    { name: 'Medicine', id: 2 },
    { name: 'Entertainment', id: 3 },
    { name: 'Sport and Movies', id: 4 },
    { name: 'Other', id: 5 },
    { name: 'Stuff', id: 6 },
    { name: 'Car', id: 7 },
    { name: 'Study', id: 8 },
  ]);

  protected month = model(new Date());
  protected currency: { name: string } = model({ name: 'USD' });
  protected status: { name: string } = model({ name: 'All' });
  protected selectedGroups = model<Group[]>([]);
}

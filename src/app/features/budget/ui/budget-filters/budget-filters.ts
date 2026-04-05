import {
  ChangeDetectionStrategy,
  Component,
  input,
  linkedSignal,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { toNameOptions } from '@core/utils/input-transforms';
import { DatePickerModule } from 'primeng/datepicker';
import { FloatLabelModule } from 'primeng/floatlabel';
import { MultiSelectModule } from 'primeng/multiselect';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';

interface GroupOption {
  id: number;
  name: string;
}

@Component({
  selector: 'app-budget-filters',
  imports: [
    FormsModule,
    TableModule,
    SelectModule,
    DatePickerModule,
    MultiSelectModule,
    FloatLabelModule,
  ],
  templateUrl: './budget-filters.html',
  host: {
    class: 'flex flex-col gap-2',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetFilters {
  readonly initialMonth = input(new Date());
  readonly initialCurrency = input<string>();
  readonly initialStatus = input('all');
  readonly initialGroupsIds = input<number[]>([]);
  readonly currencies = input<{ name: string }[], string[]>([], {
    transform: toNameOptions,
  });
  readonly groups = input<GroupOption[]>([]);
  readonly hasStatusFilter = input(true);
  readonly hasGroupsFilter = input(true);

  readonly monthChanged = output<Date>();
  readonly currencyChanged = output<string>();
  readonly statusChanged = output<string>();
  readonly groupsIdsChanged = output<number[]>();

  protected readonly month = linkedSignal(() => this.initialMonth());
  protected readonly currency = linkedSignal(() => this.initialCurrency());
  protected readonly status = linkedSignal(() => this.initialStatus());
  protected selectedGroupsIds = linkedSignal(() => this.initialGroupsIds());

  protected readonly statuses = [
    { name: 'All', value: 'all' },
    { name: 'On track', value: 'onTrack' },
    { name: 'Attention', value: 'attention' },
    { name: 'Over budget', value: 'overBudget' },
  ];
}

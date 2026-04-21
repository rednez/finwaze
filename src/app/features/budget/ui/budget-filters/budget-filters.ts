import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  linkedSignal,
  output,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LocalizationService } from '@core/services/localization.service';
import { toNameOptions } from '@core/utils/input-transforms';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
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
    TranslatePipe,
  ],
  templateUrl: './budget-filters.html',
  host: { class: 'flex flex-col gap-2' },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetFilters {
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

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

  protected readonly statuses = computed(() => [
    { name: this.t('shared.all'), value: 'all' },
    { name: this.t('budget.filters.onTrack'), value: 'onTrack' },
    { name: this.t('budget.filters.attention'), value: 'attention' },
    { name: this.t('budget.filters.overBudget'), value: 'overBudget' },
  ]);
}

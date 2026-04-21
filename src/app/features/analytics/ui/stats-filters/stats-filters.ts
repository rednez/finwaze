import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  linkedSignal,
  OnInit,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Account } from '@core/models/accounts';
import { AccountsStore } from '@core/store/accounts-store';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { DatePickerModule } from 'primeng/datepicker';
import { FloatLabelModule } from 'primeng/floatlabel';
import { MultiSelectModule } from 'primeng/multiselect';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';
import { AnalyticsStore } from '../../stores';

@Component({
  selector: 'app-stats-filters',
  imports: [
    FormsModule,
    TableModule,
    SelectModule,
    DatePickerModule,
    MultiSelectModule,
    FloatLabelModule,
    TranslatePipe,
  ],
  templateUrl: './stats-filters.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'flex gap-2 flex-wrap' },
})
export class StatsFilters implements OnInit {
  private readonly accountsStore = inject(AccountsStore);
  protected readonly analyticsStore = inject(AnalyticsStore);

  protected readonly currencies = computed(() =>
    this.accountsStore.myCurrencies().map((c) => ({ name: c })),
  );

  protected readonly accounts = computed(() =>
    this.accountsStore
      .accounts()
      .filter((a) => a.currencyCode === this.currency().name),
  );

  protected month = linkedSignal(() => this.analyticsStore.selectedMonth());

  protected currency = linkedSignal<{ name: string }>(() => ({
    name: this.analyticsStore.selectedCurrencyCode(),
  }));

  protected selectedAccounts = linkedSignal<Account[]>(() =>
    this.accountsStore
      .accounts()
      .filter((a) => this.analyticsStore.selectedAccountIds().includes(a.id)),
  );

  ngOnInit(): void {
    if (!this.analyticsStore.selectedCurrencyCode()) {
      this.analyticsStore.updateCurrencyCode(
        this.accountsStore.selectedCurrencyCode()!,
      );
    }
  }

  protected onMonthChange(month: Date): void {
    this.analyticsStore.updateMonth(month);
  }

  protected onCurrencyChange(currency: { name: string }): void {
    this.analyticsStore.updateCurrencyCode(currency.name);
    this.analyticsStore.updateAccountIds([]);
  }

  protected onAccountsChange(accounts: Account[]): void {
    this.analyticsStore.updateAccountIds(accounts.map((a) => a.id));
  }
}

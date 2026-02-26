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
import { Category, Group } from '@core/models/categories';
import { SelectDesignTokens } from '@primeuix/themes/types/select';
import { DatePickerModule } from 'primeng/datepicker';
import { IftaLabelModule } from 'primeng/iftalabel';
import { SelectModule } from 'primeng/select';
import { TableModule } from 'primeng/table';

@Component({
  selector: 'app-transactions-filters',
  imports: [
    CommonModule,
    FormsModule,
    TableModule,
    SelectModule,
    IftaLabelModule,
    DatePickerModule,
  ],
  templateUrl: './transactions-filters.html',
  host: {
    class: 'flex gap-2 flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TransactionsFilters {
  readonly initMonth = input(new Date());
  readonly initCurrency = input<string | null>();
  readonly initGroup = input<number | null>();
  readonly initCategory = input<number | null>();
  readonly currencies = input<string[]>([]);
  readonly groups = input<Group[]>([]);
  readonly categories = input<Category[]>([]);
  readonly monthChanged = output<Date>();
  readonly currencyChanged = output<string | null>();
  readonly groupChanged = output<number | null>();
  readonly categoryChanged = output<number | null>();

  protected readonly currenciesOptions = computed(() => [
    { name: 'All' },
    ...this.currencies().map((currency) => ({
      name: currency,
      value: currency,
    })),
  ]);

  protected readonly groupsOptions = computed(() => [
    { id: 0, name: 'All' },
    ...this.groups().map((group) => ({
      id: group.id,
      name: group.name,
    })),
  ]);

  protected readonly categoriesOptions = computed(() => [
    { id: 0, name: 'All' },
    ...this.categories().map((category) => ({
      id: category.id,
      name: category.name,
    })),
  ]);

  protected readonly selectInputSchema: SelectDesignTokens = {
    root: {
      borderRadius: '16px',
    },
  };

  protected selectedMonth = linkedSignal(() => this.initMonth());
  protected selectedCurrency = linkedSignal(() => this.initCurrency() || 'All');
  protected selectedGroup = linkedSignal(() => this.initGroup() || 0);
  protected selectedCategory = linkedSignal(() => this.initCategory() || 0);

  protected onMonthChange(event: Date) {
    this.selectedMonth.set(event);
    this.monthChanged.emit(event);
  }

  protected onCurrencyChange(event: string) {
    this.selectedCurrency.set(event);
    this.currencyChanged.emit(event !== 'All' ? event : null);
  }

  protected onGroupChange(event: number) {
    this.selectedGroup.set(event);
    this.groupChanged.emit(event !== 0 ? event : null);
  }

  protected onCategoryChange(event: number) {
    this.selectedCategory.set(event);
    this.categoryChanged.emit(event !== 0 ? event : null);
  }
}

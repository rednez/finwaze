import { CurrencyPipe } from '@angular/common';
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Category } from '@core/models/categories';
import { CategoriesStore } from '@core/store/categories-store';
import { ButtonModule } from 'primeng/button';
import { SelectModule } from 'primeng/select';
import { TooltipModule } from 'primeng/tooltip';
import { CreateBudgetCategoryRow } from './create-budget-category-row';
import { BudgetGroupRow } from '../../models';
import { GroupTotals } from './create-budget-store';

@Component({
  selector: 'app-create-budget-group-row',
  imports: [
    CurrencyPipe,
    FormsModule,
    ButtonModule,
    SelectModule,
    TooltipModule,
    CreateBudgetCategoryRow,
  ],
  template: `
    <div
      class="grid grid-cols-[1fr_repeat(4,minmax(110px,130px))_40px] gap-2 items-center px-4 py-3 rounded-xl bg-surface-100 dark:bg-surface-800 cursor-pointer select-none hover:bg-surface-200 dark:hover:bg-surface-700 transition-colors"
      tabindex="0"
      role="button"
      [attr.aria-expanded]="isExpanded()"
      (click)="toggled.emit()"
      (keyup.enter)="toggled.emit()"
      (keyup.space)="toggled.emit()"
    >
      <div class="flex items-center gap-2 min-w-0">
        <i
          class="pi text-surface-400 text-xs shrink-0"
          [class.pi-chevron-down]="isExpanded()"
          [class.pi-chevron-right]="!isExpanded()"
        ></i>
        <span
          class="font-semibold text-sm text-surface-800 dark:text-surface-100 truncate"
        >
          {{ groupName() }}
        </span>
        <span class="text-xs text-surface-400 shrink-0">
          {{ group().categories.length }}
        </span>
      </div>

      <span
        class="text-right text-sm font-semibold text-surface-700 dark:text-surface-200"
      >
        {{
          totals()?.plannedAmount
            | currency: currencyCode() : 'symbol' : '1.0-0'
        }}
      </span>
      <span class="text-right text-sm text-surface-500">
        {{
          totals()?.prevPlannedAmount
            | currency: currencyCode() : 'symbol' : '1.0-0'
        }}
      </span>
      <span
        class="text-right text-sm font-medium"
        [class.text-surface-700]="!isOverBudget()"
        [class.dark:text-surface-200]="!isOverBudget()"
      >
        {{
          totals()?.currentSpentAmount
            | currency: currencyCode() : 'symbol' : '1.0-0'
        }}
      </span>
      <span class="text-right text-sm text-surface-500">
        {{
          totals()?.prevSpentAmount
            | currency: currencyCode() : 'symbol' : '1.0-0'
        }}
      </span>

      <div class="flex justify-end">
        <p-button
          icon="pi pi-trash"
          severity="danger"
          variant="text"
          size="small"
          [rounded]="true"
          pTooltip="Видалити групу"
          tooltipPosition="left"
          (onClick)="removeGroup.emit()"
          (click)="$event.stopPropagation()"
        />
      </div>
    </div>

    @if (isExpanded()) {
      <div class="flex flex-col gap-0.5 ml-4 mb-1">
        @for (cat of group().categories; track cat.tempId) {
          <app-create-budget-category-row
            [category]="cat"
            [categoryName]="categoryName(cat.categoryId)"
            [currencyCode]="currencyCode()"
            [invalid]="submitted() && !cat.plannedAmount"
            (plannedChange)="
              plannedChange.emit({ categoryTempId: cat.tempId, amount: $event })
            "
            (remove)="removeCategory.emit(cat.tempId)"
          />
        }

        @if (isAddingCategory()) {
          <div
            class="flex items-center gap-2 px-4 py-2 ml-4 rounded-lg border border-dashed border-surface-300 dark:border-surface-600"
          >
            <p-select
              class="flex-1"
              [ngModel]="selectedCategoryId()"
              (ngModelChange)="selectedCategoryId.set($event)"
              [options]="availableCategories()"
              optionLabel="name"
              optionValue="id"
              placeholder="Оберіть категорію"
              [filter]="true"
              filterBy="name"
              size="small"
            />
            <p-button
              icon="pi pi-check"
              size="small"
              [rounded]="true"
              [disabled]="selectedCategoryId() === null"
              (onClick)="confirmAddCategory()"
            />
            <p-button
              icon="pi pi-times"
              severity="secondary"
              variant="text"
              size="small"
              [rounded]="true"
              (onClick)="cancelAddCategory()"
            />
          </div>
        }

        <div class="pl-4 pt-1">
          <p-button
            label="Додати категорію"
            icon="pi pi-plus"
            severity="secondary"
            variant="text"
            size="small"
            [disabled]="
              availableCategories().length === 0 && !isAddingCategory()
            "
            (onClick)="startAddCategory()"
          />
        </div>
      </div>
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CreateBudgetGroupRow {
  private readonly categoriesStore = inject(CategoriesStore);

  readonly group = input.required<BudgetGroupRow>();
  readonly groupName = input.required<string>();
  readonly totals = input<GroupTotals | undefined>();
  readonly isExpanded = input(false);
  readonly currencyCode = input('');
  readonly submitted = input(false);
  readonly availableCategories = input<Category[]>([]);

  readonly toggled = output();
  readonly removeGroup = output();
  readonly addCategory = output<number>();
  readonly removeCategory = output<number>();
  readonly plannedChange = output<{
    categoryTempId: number;
    amount: number | null;
  }>();

  protected readonly isOverBudget = computed(
    () =>
      (this.totals()?.currentSpentAmount ?? 0) >
      (this.totals()?.plannedAmount ?? 0),
  );

  private readonly categoryNameMap = computed(
    () =>
      new Map(this.categoriesStore.allCategories().map((c) => [c.id, c.name])),
  );

  protected readonly isAddingCategory = signal(false);
  protected readonly selectedCategoryId = signal<number | null>(null);

  protected categoryName(categoryId: number): string {
    return this.categoryNameMap().get(categoryId) ?? `#${categoryId}`;
  }

  protected startAddCategory(): void {
    this.isAddingCategory.set(true);
    this.selectedCategoryId.set(null);
  }

  protected confirmAddCategory(): void {
    const id = this.selectedCategoryId();
    if (id === null) return;
    this.addCategory.emit(id);
    this.isAddingCategory.set(false);
    this.selectedCategoryId.set(null);
  }

  protected cancelAddCategory(): void {
    this.isAddingCategory.set(false);
    this.selectedCategoryId.set(null);
  }
}

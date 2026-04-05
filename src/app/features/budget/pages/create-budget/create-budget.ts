import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  viewChild,
} from '@angular/core';
import { CategoriesStore } from '@core/store/categories-store';
import { EmptyState } from '@shared/ui/empty-state';
import dayjs from 'dayjs';
import { MessageService } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { ToastModule } from 'primeng/toast';
import { BudgetStore } from '../../stores';
import { CreateBudgetGroupList } from './create-budget-group-list';
import { CreateBudgetStore } from './create-budget-store';
import { CreateBudgetTotals } from './create-budget-totals';

@Component({
  imports: [
    ButtonModule,
    CreateBudgetGroupList,
    CreateBudgetTotals,
    EmptyState,
    ToastModule,
  ],
  template: `<p-toast />

    @if (store.isLoading()) {
      <div class="flex justify-center py-12">
        <i class="pi pi-spin pi-spinner text-2xl text-surface-400"></i>
      </div>
    } @else if (store.budgetExists()) {
      <div class="flex items-center justify-end flex-wrap gap-3">
        <div class="flex items-center gap-2">
          <p-button
            label="Collapse all"
            icon="pi pi-minus"
            severity="secondary"
            variant="text"
            size="small"
            (onClick)="collapseAll()"
          />
          <p-button
            label="Expand all"
            icon="pi pi-plus"
            severity="secondary"
            variant="text"
            size="small"
            (onClick)="expandAll()"
          />
          <p-button
            label="Save"
            icon="pi pi-check"
            rounded
            size="small"
            [loading]="store.isSaving()"
            [disabled]="!store.isDirty()"
            (onClick)="onSave()"
          />
        </div>
      </div>

      <app-create-budget-group-list />

      <app-create-budget-totals
        [totalPlanned]="store.totalPlanned()"
        [totalPrevPlanned]="store.totalPrevPlanned()"
        [totalSpent]="store.totalSpent()"
        [totalPrevSpent]="store.totalPrevSpent()"
        [currencyCode]="currencyCode()"
      />
    } @else {
      <app-empty-state
        [title]="emptyStateTitle()"
        description="You can generate a budget based on the previous month or create a new one manually."
        primaryButtonText="Generate"
        primaryButtonIcon="wand_stars"
        secondaryButtonText="Create manually"
        secondaryButtonIcon="hand_meal"
        icon="donut_small"
        [hasSecondaryAction]="true"
        (primaryActionClicked)="onGenerateFromPrevious()"
        (secondaryActionClicked)="store.startManual()"
      />
    }`,
  host: { class: 'flex flex-col gap-6 w-full' },
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [CreateBudgetStore, MessageService],
})
export class CreateBudget {
  protected readonly store = inject(CreateBudgetStore);
  protected readonly budgetStore = inject(BudgetStore);
  private readonly categoriesStore = inject(CategoriesStore);
  private readonly messageService = inject(MessageService);

  private readonly groupList = viewChild(CreateBudgetGroupList);

  protected readonly emptyStateTitle = computed(
    () =>
      'No budget for ' +
      dayjs(this.budgetStore.month()).format('MMMM') +
      ' in ' +
      this.budgetStore.currencyCode(),
  );

  protected readonly currencyCode = computed(
    () => this.budgetStore.currencyCode() ?? 'UAH',
  );

  protected readonly monthIso = computed(() =>
    dayjs(this.budgetStore.month()).startOf('month').format('YYYY-MM-DD'),
  );

  constructor() {
    if (!this.categoriesStore.isLoaded()) {
      this.categoriesStore.loadAll();
    }
    if (this.budgetStore.currencyCode()) {
      this.store.loadExistingBudget(this.monthIso(), this.currencyCode());
    }
  }

  protected expandAll(): void {
    this.groupList()?.expandAll();
  }

  protected collapseAll(): void {
    this.groupList()?.collapseAll();
  }

  protected async onGenerateFromPrevious(): Promise<void> {
    const result = await this.store.generateFromPreviousMonth(
      this.monthIso(),
      this.currencyCode(),
    );
    if (result.ok) {
      setTimeout(() => this.groupList()?.expandAll(), 100);
    }
  }

  protected async onSave(): Promise<void> {
    this.store.markSubmitted();
    if (!this.store.isValid()) {
      return;
    }
    const result = await this.store.saveBudget(
      this.monthIso(),
      this.currencyCode(),
    );
    if (result.ok) {
      this.messageService.add({ severity: 'success', summary: 'Budget saved' });
    } else {
      this.messageService.add({
        severity: 'error',
        summary: 'Failed to save budget',
      });
    }
  }
}

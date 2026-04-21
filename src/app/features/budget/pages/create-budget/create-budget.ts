import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  viewChild,
} from '@angular/core';
import { LocalizationService } from '@core/services/localization.service';
import { CategoriesStore } from '@core/store/categories-store';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
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
    TranslatePipe,
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
            [label]="'budget.createBudget.collapseAll' | translate"
            icon="pi pi-minus"
            severity="secondary"
            variant="text"
            size="small"
            (onClick)="collapseAll()"
          />
          <p-button
            [label]="'budget.createBudget.expandAll' | translate"
            icon="pi pi-plus"
            severity="secondary"
            variant="text"
            size="small"
            (onClick)="expandAll()"
          />
          <p-button
            [label]="'budget.createBudget.save' | translate"
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
        [description]="'budget.createBudget.canGenerate' | translate"
        [primaryButtonText]="'budget.createBudget.generate' | translate"
        primaryButtonIcon="wand_stars"
        [secondaryButtonText]="'budget.createBudget.createManually' | translate"
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
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  private readonly groupList = viewChild(CreateBudgetGroupList);

  protected readonly emptyStateTitle = computed(() => {
    this.localizationService.currentLang();
    const template = this.t('budget.createBudget.noBudget');
    return template
      .replace('{{month}}', dayjs(this.budgetStore.month()).format('MMMM'))
      .replace('{{currency}}', this.budgetStore.currencyCode() ?? '');
  });

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
    if (!this.store.isValid()) return;
    const result = await this.store.saveBudget(
      this.monthIso(),
      this.currencyCode(),
    );
    if (result.ok) {
      this.messageService.add({
        severity: 'success',
        summary: this.t('budget.createBudget.saved'),
      });
    } else {
      this.messageService.add({
        severity: 'error',
        summary: this.t('budget.createBudget.failedToSave'),
      });
    }
  }
}

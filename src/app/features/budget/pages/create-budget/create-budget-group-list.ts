import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Category, Group } from '@core/models/categories';
import { CategoriesStore } from '@core/store/categories-store';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { ButtonModule } from 'primeng/button';
import { SelectModule } from 'primeng/select';
import { BudgetStore } from '../../stores';
import { CreateBudgetGroupRow } from './create-budget-group-row';
import { BudgetGroupRow } from '../../models';
import { CreateBudgetStore } from './create-budget-store';

@Component({
  selector: 'app-create-budget-group-list',
  imports: [
    FormsModule,
    ButtonModule,
    SelectModule,
    CreateBudgetGroupRow,
    TranslatePipe,
  ],
  template: `
    <div class="flex flex-col gap-1">
      <!-- Column header -->
      <div
        class="grid grid-cols-[1fr_repeat(4,minmax(110px,130px))_40px] gap-2 px-4 py-2 text-xs font-medium text-surface-400 uppercase tracking-wider"
      >
        <span>{{ 'budget.createBudget.groupCategory' | translate }}</span>
        <span class="text-right">{{
          'budget.createBudget.planMonth' | translate
        }}</span>
        <span class="text-right">{{
          'budget.createBudget.planPrevMonth' | translate
        }}</span>
        <span class="text-right">{{
          'budget.createBudget.spentMonth' | translate
        }}</span>
        <span class="text-right">{{
          'budget.createBudget.spentPrevMonth' | translate
        }}</span>
        <span></span>
      </div>

      <!-- Group rows -->
      @for (group of store.groups(); track group.tempId) {
        <app-create-budget-group-row
          [group]="group"
          [groupName]="groupName(group.groupId)"
          [totals]="groupTotal(group.tempId)"
          [isExpanded]="isExpanded(group.tempId)"
          [currencyCode]="currencyCode()"
          [submitted]="store.submitted()"
          [availableCategories]="availableCategoriesForGroup(group)"
          (toggled)="toggleGroup(group.tempId)"
          (removeGroup)="store.removeGroup(group.tempId)"
          (addCategory)="store.addCategory(group.tempId, $event)"
          (removeCategory)="store.removeCategory(group.tempId, $event)"
          (plannedChange)="
            store.updateCategoryPlanned(
              group.tempId,
              $event.categoryTempId,
              $event.amount ?? 0
            )
          "
        />
      }

      <!-- Add group row -->
      @if (isAddingGroup()) {
        <div
          class="flex items-center gap-2 px-4 py-3 rounded-xl border border-dashed border-primary-300 dark:border-primary-700 bg-primary-50 dark:bg-primary-950"
        >
          <p-select
            class="flex-1"
            [ngModel]="selectedNewGroupId()"
            (ngModelChange)="selectedNewGroupId.set($event)"
            [options]="availableGroups()"
            optionLabel="name"
            optionValue="id"
            [placeholder]="'budget.createBudget.selectGroup' | translate"
            [filter]="true"
            filterBy="name"
            size="small"
          />
          <p-button
            icon="pi pi-check"
            size="small"
            [rounded]="true"
            [disabled]="selectedNewGroupId() === null"
            (onClick)="onConfirmAddGroup()"
          />
          <p-button
            icon="pi pi-times"
            severity="secondary"
            variant="text"
            size="small"
            [rounded]="true"
            (onClick)="onCancelAddGroup()"
          />
        </div>
      } @else {
        <div class="pt-2">
          <p-button
            [label]="'budget.createBudget.addGroup' | translate"
            icon="pi pi-plus"
            severity="secondary"
            variant="outlined"
            [rounded]="true"
            size="small"
            [disabled]="availableGroups().length === 0"
            (onClick)="isAddingGroup.set(true)"
          />
        </div>
      }
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CreateBudgetGroupList {
  protected readonly store = inject(CreateBudgetStore);
  private readonly budgetStore = inject(BudgetStore);
  private readonly categoriesStore = inject(CategoriesStore);

  protected readonly expandedGroups = signal<Set<number>>(new Set());
  protected readonly isAddingGroup = signal(false);
  protected readonly selectedNewGroupId = signal<number | null>(null);

  protected readonly currencyCode = computed(
    () => this.budgetStore.currencyCode() ?? 'UAH',
  );

  protected readonly availableGroups = computed((): Group[] => {
    const usedIds = new Set(this.store.selectedGroupIds());
    return this.categoriesStore
      .expensesGroups()
      .filter((g) => !usedIds.has(g.id));
  });

  expandAll(): void {
    this.expandedGroups.set(new Set(this.store.groups().map((g) => g.tempId)));
  }

  collapseAll(): void {
    this.expandedGroups.set(new Set());
  }

  protected groupName(groupId: number): string {
    return (
      this.categoriesStore.allGroups().find((g) => g.id === groupId)?.name ??
      `#${groupId}`
    );
  }

  protected availableCategoriesForGroup(group: BudgetGroupRow): Category[] {
    const usedCategoryIds = new Set(group.categories.map((c) => c.categoryId));
    return this.categoriesStore
      .allCategories()
      .filter((c) => c.groupId === group.groupId && !usedCategoryIds.has(c.id));
  }

  protected groupTotal(tempId: number) {
    return this.store.groupTotals().find((g) => g.tempId === tempId);
  }

  protected isExpanded(tempId: number): boolean {
    return this.expandedGroups().has(tempId);
  }

  protected toggleGroup(tempId: number): void {
    const next = new Set(this.expandedGroups());
    if (next.has(tempId)) {
      next.delete(tempId);
    } else {
      next.add(tempId);
    }
    this.expandedGroups.set(next);
  }

  protected onConfirmAddGroup(): void {
    const id = this.selectedNewGroupId();
    if (id === null) return;
    this.store.addGroup(id);
    this.selectedNewGroupId.set(null);
    this.isAddingGroup.set(false);
  }

  protected onCancelAddGroup(): void {
    this.selectedNewGroupId.set(null);
    this.isAddingGroup.set(false);
  }
}

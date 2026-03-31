import { computed, inject } from '@angular/core';
import { Result } from '@core/models/result';
import { resultError, resultOk } from '@core/utils/result-factory';
import {
  patchState,
  signalStore,
  withComputed,
  withMethods,
  withState,
} from '@ngrx/signals';
import dayjs from 'dayjs';
import { BudgetCategoryRow, BudgetGroupRow } from '../../models';
import { BudgetMapper } from '../../mappers';
import { BudgetRepository } from '../../repositories';
import { BudgetStore } from '../../stores';

function groupsEqual(a: BudgetGroupRow[], b: BudgetGroupRow[]): boolean {
  if (a.length !== b.length) return false;
  const sortedA = [...a].sort((x, y) => x.groupId - y.groupId);
  const sortedB = [...b].sort((x, y) => x.groupId - y.groupId);
  return sortedA.every((ga, i) => {
    const gb = sortedB[i];
    if (ga.groupId !== gb.groupId) return false;
    if (ga.categories.length !== gb.categories.length) return false;
    const catsA = [...ga.categories].sort(
      (x, y) => x.categoryId - y.categoryId,
    );
    const catsB = [...gb.categories].sort(
      (x, y) => x.categoryId - y.categoryId,
    );
    return catsA.every(
      (ca, j) =>
        ca.categoryId === catsB[j].categoryId &&
        ca.plannedAmount === catsB[j].plannedAmount,
    );
  });
}

function updateGroup(
  groups: BudgetGroupRow[],
  groupTempId: number,
  updater: (g: BudgetGroupRow) => BudgetGroupRow,
): BudgetGroupRow[] {
  return groups.map((g) => (g.tempId === groupTempId ? updater(g) : g));
}

export interface GroupTotals {
  tempId: number;
  plannedAmount: number;
  prevPlannedAmount: number;
  currentSpentAmount: number;
  prevSpentAmount: number;
}

interface CreateBudgetState {
  budgetExists: boolean;
  isLoading: boolean;
  isSaving: boolean;
  isGenerating: boolean;
  submitted: boolean;
  cleanGroups: BudgetGroupRow[];
  groups: BudgetGroupRow[];
  nextTempId: number;
}

const initialState: CreateBudgetState = {
  budgetExists: false,
  isLoading: false,
  isSaving: false,
  isGenerating: false,
  submitted: false,
  cleanGroups: [],
  groups: [],
  nextTempId: 1000,
};

export const CreateBudgetStore = signalStore(
  withState(initialState),

  withComputed((store) => ({
    totalPlanned: computed(() =>
      store
        .groups()
        .flatMap((g) => g.categories)
        .reduce((sum, c) => sum + (c.plannedAmount || 0), 0),
    ),
    totalPrevPlanned: computed(() =>
      store
        .groups()
        .flatMap((g) => g.categories)
        .reduce((sum, c) => sum + c.prevPlannedAmount, 0),
    ),
    totalSpent: computed(() =>
      store
        .groups()
        .flatMap((g) => g.categories)
        .reduce((sum, c) => sum + c.currentSpentAmount, 0),
    ),
    totalPrevSpent: computed(() =>
      store
        .groups()
        .flatMap((g) => g.categories)
        .reduce((sum, c) => sum + c.prevSpentAmount, 0),
    ),
    selectedGroupIds: computed(() => store.groups().map((g) => g.groupId)),
    isDirty: computed(() => !groupsEqual(store.groups(), store.cleanGroups())),
    isValid: computed(() =>
      store
        .groups()
        .flatMap((g) => g.categories)
        .every((c) => c.plannedAmount > 0),
    ),
    groupTotals: computed((): GroupTotals[] =>
      store.groups().map((g) => {
        const zero = {
          plannedAmount: 0,
          prevPlannedAmount: 0,
          currentSpentAmount: 0,
          prevSpentAmount: 0,
        };
        const totals = g.categories.reduce(
          (acc, c) => ({
            plannedAmount: acc.plannedAmount + (c.plannedAmount || 0),
            prevPlannedAmount: acc.prevPlannedAmount + c.prevPlannedAmount,
            currentSpentAmount: acc.currentSpentAmount + c.currentSpentAmount,
            prevSpentAmount: acc.prevSpentAmount + c.prevSpentAmount,
          }),
          zero,
        );
        return { tempId: g.tempId, ...totals };
      }),
    ),
  })),

  withMethods(
    (
      store,
      repository = inject(BudgetRepository),
      mapper = inject(BudgetMapper),
      budgetStore = inject(BudgetStore),
    ) => {
      function nextId(): number {
        const id = store.nextTempId();
        patchState(store, { nextTempId: id + 1 });
        return id;
      }

      return {
        async loadExistingBudget(
          month: string,
          currencyCode: string,
        ): Promise<Result> {
          patchState(store, { isLoading: true });
          try {
            const dtos = await repository.getDetailedMonthlyBudgets({
              month,
              currencyCode,
            });
            const hasBudget = dtos.some((d) => d.planned_amount > 0);
            if (hasBudget) {
              const budgetedDtos = dtos.filter((d) => d.planned_amount > 0);
              const groups =
                mapper.fromDetailedBudgetDtosToGroupRows(budgetedDtos);
              patchState(store, {
                groups,
                cleanGroups: groups,
                budgetExists: true,
                isLoading: false,
              });
            } else {
              patchState(store, { isLoading: false });
            }
            return resultOk();
          } catch (error) {
            patchState(store, { isLoading: false });
            return resultError(error);
          }
        },

        async generateFromPreviousMonth(
          month: string,
          currencyCode: string,
        ): Promise<Result> {
          patchState(store, { isGenerating: true });
          try {
            const dtos = await repository.generateBudgetsFromPrevious({
              month,
              currencyCode,
            });
            const groups = mapper.fromDetailedBudgetDtosToGroupRows(dtos);
            patchState(store, {
              groups,
              cleanGroups: [],
              budgetExists: true,
              isGenerating: false,
            });
            return resultOk();
          } catch (error) {
            patchState(store, { isGenerating: false });
            return resultError(error);
          }
        },

        startManual(): void {
          patchState(store, {
            groups: [],
            cleanGroups: [],
            budgetExists: true,
          });
        },

        addGroup(groupId: number): void {
          const newGroup: BudgetGroupRow = {
            tempId: nextId(),
            groupId,
            categories: [],
          };
          patchState(store, { groups: [...store.groups(), newGroup] });
        },

        removeGroup(groupTempId: number): void {
          patchState(store, {
            groups: store.groups().filter((g) => g.tempId !== groupTempId),
          });
        },

        async addCategory(
          groupTempId: number,
          categoryId: number,
        ): Promise<void> {
          const tempId = nextId();
          const newCategory: BudgetCategoryRow = {
            tempId,
            categoryId,
            plannedAmount: 0,
            prevPlannedAmount: 0,
            currentSpentAmount: 0,
            prevSpentAmount: 0,
          };
          patchState(store, {
            groups: updateGroup(store.groups(), groupTempId, (g) => ({
              ...g,
              categories: [...g.categories, newCategory],
            })),
          });

          const month = budgetStore.month();
          const currencyCode = budgetStore.currencyCode();
          if (!currencyCode) return;

          const stats = await repository.getCategoryBudgetStats({
            month: dayjs(month).format('YYYY-MM-DD'),
            currencyCode,
            categoryId,
          });

          patchState(store, {
            groups: updateGroup(store.groups(), groupTempId, (g) => ({
              ...g,
              categories: g.categories.map((c) =>
                c.tempId === tempId
                  ? {
                      ...c,
                      prevPlannedAmount: stats.prevPlannedAmount,
                      currentSpentAmount: stats.currentSpentAmount,
                      prevSpentAmount: stats.prevSpentAmount,
                    }
                  : c,
              ),
            })),
          });
        },

        removeCategory(groupTempId: number, categoryTempId: number): void {
          patchState(store, {
            groups: updateGroup(store.groups(), groupTempId, (g) => ({
              ...g,
              categories: g.categories.filter(
                (c) => c.tempId !== categoryTempId,
              ),
            })),
          });
        },

        updateCategoryPlanned(
          groupTempId: number,
          categoryTempId: number,
          amount: number,
        ): void {
          patchState(store, {
            groups: updateGroup(store.groups(), groupTempId, (g) => ({
              ...g,
              categories: g.categories.map((c) =>
                c.tempId === categoryTempId
                  ? { ...c, plannedAmount: amount }
                  : c,
              ),
            })),
          });
        },

        markSubmitted(): void {
          patchState(store, { submitted: true });
        },

        async saveBudget(month: string, currencyCode: string): Promise<Result> {
          patchState(store, { isSaving: true });
          const categories = store.groups().flatMap((g) =>
            g.categories.map((c) => ({
              category_id: c.categoryId,
              planned_amount: c.plannedAmount,
            })),
          );
          try {
            await repository.upsertMonthlyBudgets({
              month,
              currencyCode,
              categories,
            });
            const savedGroups = store.groups();
            patchState(store, {
              isSaving: false,
              cleanGroups: savedGroups,
              submitted: false,
            });
            return resultOk();
          } catch (error) {
            patchState(store, { isSaving: false });
            return resultError(error);
          }
        },
      };
    },
  ),
);

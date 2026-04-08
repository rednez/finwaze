import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { ButtonModule } from 'primeng/button';

@Component({
  selector: 'app-empty-goals-list-state',
  imports: [ButtonModule, RouterLink],
  template: `
    <div class="relative">
      <div
        class="absolute inset-0 rounded-full bg-linear-to-br from-violet-200/60 to-purple-200/40 dark:from-violet-500/20 dark:to-purple-500/15 blur-xl scale-125"
      ></div>
      <div
        class="relative flex items-center justify-center w-16 h-16 rounded-2xl bg-linear-to-br from-violet-100 to-purple-100 dark:from-violet-900/40 dark:to-purple-900/35 border border-violet-100 dark:border-violet-800/40 shadow-lg shadow-violet-200/50 dark:shadow-violet-900/40"
      >
        <span class="material-symbols-rounded text-violet-500 text-3xl">
          savings
        </span>
      </div>
    </div>
    <div>
      <p class="font-semibold text-surface-800 dark:text-surface-100 mb-1">
        No goals yet
      </p>
      <p class="text-sm text-muted-color">
        Add your first savings goal to start tracking progress.
      </p>
    </div>
    <p-button
      icon="pi pi-plus"
      label="Add new goal"
      [rounded]="true"
      size="large"
      class="shrink-0"
      [dt]="{ root: { lg: { fontSize: '14px' } } }"
      [routerLink]="['create']"
    />
  `,
  host: {
    class:
      'w-full flex flex-col items-center justify-center gap-4 py-12 px-8 text-center border-2 border-dashed border-surface-200 dark:border-surface-700 rounded-3xl',
  },
})
export class EmptyGoalsListState {}

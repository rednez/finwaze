import { CommonModule } from '@angular/common';
import { Component, computed, signal } from '@angular/core';
import { ProgressBarDesignTokens } from '@primeuix/themes/types/progressbar';
import { Card } from '@ui';
import { ProgressBarModule } from 'primeng/progressbar';

@Component({
  selector: 'app-saving-goals-widget',
  imports: [CommonModule, Card, ProgressBarModule],
  template: `
    <app-card>
      <div class="text-lg font-medium mb-5">Saving goals</div>

      <div class="flex flex-col gap-4">
        @for (goal of formattedGoals(); track goal.id) {
          <div>
            <div class="flex justify-between gap-1 text-sm mb-1">
              <div class="font-medium max-w-50 truncate">{{ goal.name }}</div>
              <div class="text-primary-500">
                {{ goal.targetAmount | currency: goal.currency }}
              </div>
            </div>
            <p-progressbar
              [value]="goal.savedAmountPercent"
              [dt]="progressSchema"
            />
          </div>
        }
      </div>
    </app-card>
  `,
})
export class SavingGoalsWidget {
  readonly goals = signal([
    {
      id: 1,
      name: 'Ford Mustang GT',
      targetAmount: 20000,
      currentAmount: 2200,
      currency: '$',
    },
    {
      id: 2,
      name: 'iPhone 18 Pro Max Super',
      targetAmount: 2100,
      currentAmount: 876,
      currency: '$',
    },
    {
      id: 3,
      name: 'Trip to Japan',
      targetAmount: 5000,
      currentAmount: 3900,
      currency: '$',
    },
  ]);

  readonly formattedGoals = computed(() =>
    this.goals().map((i) => ({
      ...i,
      savedAmountPercent: Math.floor((i.currentAmount / i.targetAmount) * 100),
    })),
  );

  protected readonly progressSchema: ProgressBarDesignTokens = {
    root: {
      height: '29px',
      borderRadius: '12px',
    },
    colorScheme: {
      light: {
        root: {
          background: 'var(--p-primary-100)',
        },
      },
      dark: {
        root: {
          background: 'var(--p-gray-700)',
        },
      },
    },
  };
}

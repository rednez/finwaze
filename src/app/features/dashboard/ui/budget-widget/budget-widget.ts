import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
} from '@angular/core';
import { LocalizationService } from '@core/services/localization.service';
import { generateAnalogColors } from '@core/utils/colors';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
import { Card } from '@shared/ui/card';
import { CardEmptyState } from '@shared/ui/card-empty-state';
import { CardHeaderTitle } from '@shared/ui/card-header-title/card-header-title';
import { CardHeader } from '@shared/ui/card-header/card-header';
import { DonutSummaryChart } from '@shared/ui/donut-summary-chart';
import { v4 } from 'uuid';

@Component({
  selector: 'app-budget-widget',
  imports: [
    Card,
    DonutSummaryChart,
    CardHeader,
    CardHeaderTitle,
    CardEmptyState,
    TranslatePipe,
  ],
  template: `
    <app-card>
      <app-card-header>
        <app-card-header-title>{{
          'dashboard.budgetWidget.title' | translate
        }}</app-card-header-title>
      </app-card-header>

      @if (categories().length > 0) {
        <div class="flex gap-2 items-center">
          <div>
            @for (cat of displayedCategories(); track cat.id) {
              <div class="flex gap-2 items-center">
                <span
                  class="block rounded-full size-2"
                  [style]="{ backgroundColor: cat.color }"
                ></span>
                <span class="text-sm/6">{{ cat.name }}</span>
              </div>
            }
          </div>

          <app-donut-summary-chart
            [title]="'dashboard.budgetWidget.totalForMonth' | translate"
            [currency]="currency()"
            [items]="displayedCategories()"
          />
        </div>
      } @else {
        <app-card-empty-state
          [title]="'dashboard.budgetWidget.noBudgets' | translate"
          [actionText]="'dashboard.budgetWidget.createBudgetText' | translate"
          [actionBtnLabel]="'dashboard.budgetWidget.gotoBudget' | translate"
          (actionBtnClicked)="actionClicked.emit()"
        />
      }
    </app-card>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BudgetWidget {
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  readonly categories = input<{ name: string; amount: number }[]>([]);
  readonly currency = input<string>();
  readonly actionClicked = output<void>();

  protected readonly displayedCategories = computed(() => {
    const colors = generateAnalogColors(this.categories().length);
    this.localizationService.currentLang();

    const sortedCategories = this.categories()
      .sort((a, b) => b.amount - a.amount)
      .map((cat, index) => ({
        ...cat,
        id: v4(),
        color: colors[index],
      }));

    return this.categories().length <= 7
      ? sortedCategories
      : [
          ...sortedCategories.slice(0, 6),
          {
            id: v4(),
            name: this.t('dashboard.budgetWidget.restCategories'),
            amount: sortedCategories
              .slice(6)
              .reduce((sum, cat) => sum + cat.amount, 0),
            color: '#e2e1e3',
          },
        ];
  });
}

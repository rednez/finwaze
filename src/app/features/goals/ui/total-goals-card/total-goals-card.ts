import { ChangeDetectionStrategy, Component, model } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Card } from '@ui/card';
import { CardHeaderTitle } from '@ui/card-header-title/card-header-title';
import { CardHeader } from '@ui/card-header/card-header';
import { DatePicker } from 'primeng/datepicker';
import { TotalGoalItem } from '../total-goal-item/total-goal-item';

@Component({
  selector: 'app-total-goals-card',
  imports: [
    FormsModule,
    Card,
    CardHeader,
    CardHeaderTitle,
    TotalGoalItem,
    DatePicker,
  ],
  template: `
    <app-card class="sm:w-89">
      <app-card-header class="flex justify-between">
        <app-card-header-title>Total Goals</app-card-header-title>

        <p-datepicker
          [(ngModel)]="date"
          view="year"
          dateFormat="yy"
          [readonlyInput]="true"
          class="w-22"
          [inputStyle]="{
            borderRadius: '16px',
            fontSize: '14px',
            height: '42px',
          }"
        />
      </app-card-header>

      <div class="text-3xl font-semibold mt-6 mb-8">25</div>

      <div class="flex gap-2 flex-wrap">
        <app-total-goal-item status="notStarted" [count]="2" />
        <app-total-goal-item status="inProgress" [count]="1" />
        <app-total-goal-item status="cancelled" [count]="3" />
        <app-total-goal-item status="done" [count]="1" />
      </div>
    </app-card>
  `,
  styles: ``,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TotalGoalsCard {
  protected date = model(new Date());
}

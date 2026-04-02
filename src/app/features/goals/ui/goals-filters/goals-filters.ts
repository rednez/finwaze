import {
  ChangeDetectionStrategy,
  Component,
  inject,
  linkedSignal,
  signal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { GoalStatus } from '@core/models/savings-goal';
import { DatePickerModule } from 'primeng/datepicker';
import { FloatLabelModule } from 'primeng/floatlabel';
import { SelectModule } from 'primeng/select';
import { GoalsListStore } from '../../stores/goals-list-store';

interface StatusOption {
  label: string;
  value: GoalStatus | null;
}

@Component({
  selector: 'app-goals-filters',
  imports: [FormsModule, SelectModule, DatePickerModule, FloatLabelModule],
  templateUrl: './goals-filters.html',
  host: {
    class: 'flex gap-2 flex-wrap',
  },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoalsFilters {
  private readonly goalsListStore = inject(GoalsListStore);

  protected readonly statuses = signal<StatusOption[]>([
    { label: 'All', value: null },
    { label: 'Not started', value: 'notStarted' },
    { label: 'In progress', value: 'inProgress' },
    { label: 'Done', value: 'done' },
    { label: 'Cancelled', value: 'cancelled' },
  ]);

  protected readonly year = linkedSignal(() => this.goalsListStore.selectedYear());

  protected readonly status = linkedSignal(
    () =>
      this.statuses().find(
        (s) => s.value === this.goalsListStore.selectedStatus(),
      ) ?? this.statuses()[0],
  );

  protected onYearChange(date: Date): void {
    this.goalsListStore.updateYear(date);
  }

  protected onStatusChange(option: StatusOption): void {
    this.goalsListStore.updateStatus(option.value);
  }
}

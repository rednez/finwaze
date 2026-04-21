import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  linkedSignal,
} from '@angular/core';
import { FormsModule } from '@angular/forms';
import { GoalStatus } from '@core/models/savings-goal';
import { LocalizationService } from '@core/services/localization.service';
import { TranslatePipe } from '@shared/pipes/translate.pipe';
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
  imports: [
    FormsModule,
    SelectModule,
    DatePickerModule,
    FloatLabelModule,
    TranslatePipe,
  ],
  templateUrl: './goals-filters.html',
  host: { class: 'flex gap-2 flex-wrap' },
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class GoalsFilters {
  private readonly goalsListStore = inject(GoalsListStore);
  private readonly localizationService = inject(LocalizationService);
  private t = (key: string) => this.localizationService.translate(key);

  protected readonly statuses = computed<StatusOption[]>(() => [
    { label: this.t('shared.all'), value: null },
    { label: this.t('goals.filters.notStarted'), value: 'notStarted' },
    { label: this.t('goals.filters.inProgress'), value: 'inProgress' },
    { label: this.t('goals.filters.done'), value: 'done' },
    { label: this.t('goals.filters.cancelled'), value: 'cancelled' },
  ]);

  protected readonly year = linkedSignal(() =>
    this.goalsListStore.selectedYear(),
  );

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

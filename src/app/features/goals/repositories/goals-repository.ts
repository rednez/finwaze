import { inject, Injectable } from '@angular/core';
import { SavingsGoalsMapper } from '@core/mappers/savings-goals-mapper';
import { GoalStatus, SavingsGoal } from '@core/models/savings-goal';
import { SupabaseService } from '@core/services/supabase.service';
import dayjs from 'dayjs';

type DbGoalStatus = 'not_started' | 'in_progress' | 'done' | 'cancelled';

export interface MonthlySavingsOverview {
  month: string;
  currentYearAmount: number;
  previousYearAmount: number;
}

interface MonthlySavingsOverviewDto {
  month: string;
  current_year_amount: number;
  previous_year_amount: number;
}

@Injectable({
  providedIn: 'root',
})
export class GoalsRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(SavingsGoalsMapper);

  async getGoals(params: {
    year?: Date | null;
    status?: GoalStatus | null;
  } = {}): Promise<SavingsGoal[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_savings_goals', {
        ...(params.year != null && {
          p_period_to: dayjs(params.year).endOf('year').format('YYYY-MM-DD'),
        }),
        ...(params.status != null && {
          p_status: this.toDbStatus(params.status),
        }),
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromSavingsGoalDto);
  }

  async getSavingsOverview(params: {
    year: Date;
    currencyCode: string;
  }): Promise<MonthlySavingsOverview[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_savings_overview', {
        p_year: dayjs(params.year).year(),
        p_currency_code: params.currencyCode,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return (data as MonthlySavingsOverviewDto[]).map((row) => ({
      month: row.month,
      currentYearAmount: row.current_year_amount,
      previousYearAmount: row.previous_year_amount,
    }));
  }

  private toDbStatus(status: GoalStatus): DbGoalStatus {
    const map: Record<GoalStatus, DbGoalStatus> = {
      notStarted: 'not_started',
      inProgress: 'in_progress',
      done: 'done',
      cancelled: 'cancelled',
    };
    return map[status];
  }
}

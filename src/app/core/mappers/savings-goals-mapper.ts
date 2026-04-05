import { Injectable } from '@angular/core';
import { SavingsGoal } from '@core/models/savings-goal';

@Injectable({
  providedIn: 'root',
})
export class SavingsGoalsMapper {
  fromSavingsGoalDto = (dto: {
    id: number;
    name: string;
    currency_code: string;
    target_date: string;
    status: 'not_started' | 'in_progress' | 'done' | 'cancelled';
    target_amount: number;
    accumulated_amount: number;
  }): SavingsGoal => {
    return {
      id: dto.id,
      name: dto.name,
      targetAmount: dto.target_amount,
      accumulatedAmount: dto.accumulated_amount,
      currencyCode: dto.currency_code,
      targetDate: new Date(dto.target_date),
      status: this.mapStatus(dto.status),
    };
  };

  private mapStatus = (
    status: 'not_started' | 'in_progress' | 'done' | 'cancelled',
  ): SavingsGoal['status'] => {
    switch (status) {
      case 'not_started':
        return 'notStarted';
      case 'in_progress':
        return 'inProgress';
      case 'done':
        return 'done';
      case 'cancelled':
        return 'cancelled';
    }
  };
}

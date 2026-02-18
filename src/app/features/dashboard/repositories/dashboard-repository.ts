import { inject, Injectable } from '@angular/core';
import { TransactionsMapper } from '@core/mappers/transactions-mapper';
import { Transaction } from '@core/models/transactions';
import { SupabaseService } from '@core/services/supabase.service';
import { DashboardMapper } from '../mappers';
import { MonthlyCashFlow, TotalSummaries } from '../models';

@Injectable({
  providedIn: 'root',
})
export class DashboardRepository {
  private readonly supabase = inject(SupabaseService);
  private readonly mapper = inject(DashboardMapper);
  private readonly transactionsMapper = inject(TransactionsMapper);

  async getTotals(currencyCode: string): Promise<TotalSummaries> {
    const { data, error } = await this.supabase.client
      .rpc('get_dashboard_totals', {
        p_currency_code: currencyCode,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return this.mapper.fromTotalsSummaryDto(data[0]);
  }

  async getMonthlyCashFlow(
    currencyCode: string,
    months: number,
  ): Promise<MonthlyCashFlow[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_monthly_cash_flow', {
        p_currency_code: currencyCode,
        p_months: months,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.mapper.fromMonthlyCashFlowDto);
  }

  async getRecentTransactions(currencyCode: string): Promise<Transaction[]> {
    const { data, error } = await this.supabase.client
      .rpc('get_recent_transactions', {
        p_account_currency_code: currencyCode,
        p_size: 3,
      })
      .select();

    if (error) {
      throw new Error(error.message);
    }

    return data.map(this.transactionsMapper.fromTransactionDto);
  }
}

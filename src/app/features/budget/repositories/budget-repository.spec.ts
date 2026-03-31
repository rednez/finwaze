import { TestBed } from '@angular/core/testing';
import { SupabaseService } from '@core/services/supabase.service';

import { BudgetRepository } from './budget-repository';

function makeSupabaseMock(rpcResult: { data?: unknown; error?: { message: string } | null }) {
  const rpcFn = vi.fn().mockReturnValue({
    select: vi.fn().mockResolvedValue(rpcResult),
    then: undefined,
    // Allow direct await (for upsertMonthlyBudgets which doesn't chain .select())
    ...('error' in rpcResult && !('data' in rpcResult)
      ? { then: (resolve: (v: typeof rpcResult) => void) => Promise.resolve(rpcResult).then(resolve) }
      : {}),
  });

  return {
    provide: SupabaseService,
    useValue: { client: { rpc: rpcFn } },
  };
}

describe('BudgetRepository', () => {
  describe('getDetailedMonthlyBudgets', () => {
    it('returns data on success', async () => {
      const dto = { category_id: 1, category_name: 'Food', group_id: 10, group_name: 'Living', planned_amount: 100, previous_planned_amount: 80, spent_amount: 50, previous_spent_amount: 40, is_unplanned: false };
      TestBed.configureTestingModule({
        providers: [makeSupabaseMock({ data: [dto], error: null })],
      });
      const repo = TestBed.inject(BudgetRepository);
      const result = await repo.getDetailedMonthlyBudgets({ month: '2026-03-01', currencyCode: 'USD' });
      expect(result).toEqual([dto]);
    });

    it('throws on error', async () => {
      TestBed.configureTestingModule({
        providers: [makeSupabaseMock({ data: null, error: { message: 'DB error' } })],
      });
      const repo = TestBed.inject(BudgetRepository);
      await expect(repo.getDetailedMonthlyBudgets({ month: '2026-03-01', currencyCode: 'USD' })).rejects.toThrow('DB error');
    });
  });

  describe('upsertMonthlyBudgets', () => {
    it('resolves with empty categories array', async () => {
      const rpcFn = vi.fn().mockResolvedValue({ error: null });
      TestBed.configureTestingModule({
        providers: [{ provide: SupabaseService, useValue: { client: { rpc: rpcFn } } }],
      });
      const repo = TestBed.inject(BudgetRepository);
      await expect(repo.upsertMonthlyBudgets({ month: '2026-03-01', currencyCode: 'USD', categories: [] })).resolves.toBeUndefined();
    });

    it('throws on error', async () => {
      const rpcFn = vi.fn().mockResolvedValue({ error: { message: 'Upsert failed' } });
      TestBed.configureTestingModule({
        providers: [{ provide: SupabaseService, useValue: { client: { rpc: rpcFn } } }],
      });
      const repo = TestBed.inject(BudgetRepository);
      await expect(repo.upsertMonthlyBudgets({ month: '2026-03-01', currencyCode: 'USD', categories: [] })).rejects.toThrow('Upsert failed');
    });
  });
});

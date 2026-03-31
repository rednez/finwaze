import { TestBed } from '@angular/core/testing';

import { WalletMapper } from './wallet-mapper';

describe('WalletMapper', () => {
  let mapper: WalletMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(WalletMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromRegularAccountDto', () => {
    it('maps all dto fields to RegularAccount', () => {
      const result = mapper.fromRegularAccountDto({
        id: 1,
        name: 'Main Wallet',
        currency_id: 10,
        currency_code: 'USD',
        balance: 5000,
        can_delete: true,
      });

      expect(result).toEqual({
        id: 1,
        name: 'Main Wallet',
        currency: { id: 10, code: 'USD' },
        balance: 5000,
        canDelete: true,
      });
    });

    it('nests currency_id and currency_code into currency object', () => {
      const result = mapper.fromRegularAccountDto({
        id: 2,
        name: 'Euro',
        currency_id: 3,
        currency_code: 'EUR',
        balance: 0,
        can_delete: false,
      });

      expect(result.currency).toEqual({ id: 3, code: 'EUR' });
    });

    it('maps can_delete to canDelete', () => {
      const result = mapper.fromRegularAccountDto({
        id: 1,
        name: 'Test',
        currency_id: 1,
        currency_code: 'UAH',
        balance: 100,
        can_delete: false,
      });

      expect(result.canDelete).toBe(false);
    });
  });

  describe('fromDailyTransactionCashFlowItemDto', () => {
    it('maps day to label and applies Math.abs to expense', () => {
      const result = mapper.fromDailyTransactionCashFlowItemDto({
        day: '2026-03-15',
        total_expense: -800,
        total_income: 1200,
      });

      expect(result).toEqual({
        label: '2026-03-15',
        expense: 800,
        income: 1200,
      });
    });

    it('converts positive expense via Math.abs (no-op)', () => {
      const result = mapper.fromDailyTransactionCashFlowItemDto({
        day: '2026-03-01',
        total_expense: 500,
        total_income: 0,
      });

      expect(result.expense).toBe(500);
    });

    it('handles zero values', () => {
      const result = mapper.fromDailyTransactionCashFlowItemDto({
        day: '2026-03-01',
        total_expense: 0,
        total_income: 0,
      });

      expect(result.expense).toBe(0);
      expect(result.income).toBe(0);
    });
  });

  describe('fromMonthlySummaryDto', () => {
    it('maps group_name to groupName and applies Math.abs to expense', () => {
      const result = mapper.fromMonthlySummaryDto({
        group_name: 'Transport',
        total_expense: -350,
        total_income: 0,
      });

      expect(result).toEqual({
        groupName: 'Transport',
        totalExpense: 350,
        totalIncome: 0,
      });
    });

    it('keeps positive total_expense as-is via Math.abs', () => {
      const result = mapper.fromMonthlySummaryDto({
        group_name: 'Food',
        total_expense: 200,
        total_income: 100,
      });

      expect(result.totalExpense).toBe(200);
      expect(result.totalIncome).toBe(100);
    });
  });
});

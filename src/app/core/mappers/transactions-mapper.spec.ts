import { TestBed } from '@angular/core/testing';

import {
  TransactionDetailsDto,
  TransactionDto,
} from '@core/models/transactions';
import { TransactionsMapper } from './transactions-mapper';

function makeTransactionDto(
  overrides: Partial<TransactionDto> = {},
): TransactionDto {
  return {
    id: 1,
    transacted_at: '2026-03-15T10:00:00Z',
    local_offset: '+02:00:00',
    transaction_amount: 100,
    transaction_currency_code: 'EUR',
    account_id: 5,
    account_name: 'Main',
    charged_amount: 4200,
    charged_currency_code: 'UAH',
    exchange_rate: 42,
    type: 'expense',
    category_id: 3,
    category_name: 'Fuel',
    group_id: 10,
    group_name: 'Transport',
    comment: 'gas station',
    transfer_id: '',
    ...overrides,
  };
}

function makeTransactionDetailsDto(
  overrides: Partial<TransactionDetailsDto> = {},
): TransactionDetailsDto {
  return {
    id: 1,
    transacted_at: '2026-03-15T10:00:00Z',
    local_offset: '+02:00:00',
    transaction_amount: 100,
    charged_amount: 4200,
    type: 'expense',
    comment: 'gas station',
    account: { id: 5, name: 'Main' },
    transaction_currency: { code: 'EUR' },
    charged_currency: { code: 'UAH' },
    category: {
      id: 3,
      name: 'Fuel',
      group: { id: 10, name: 'Transport' },
    },
    transfer_id: '',
    ...overrides,
  };
}

describe('TransactionsMapper', () => {
  let mapper: TransactionsMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(TransactionsMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromTransactionDto', () => {
    it('maps all flat dto fields to Transaction model', () => {
      const dto = makeTransactionDto();
      const result = mapper.fromTransactionDto(dto);

      expect(result).toEqual({
        id: 1,
        account: { id: 5, name: 'Main' },
        transactedAt: new Date('2026-03-15T10:00:00Z'),
        localOffset: '+02:00',
        transactionAmount: 100,
        transactionCurrency: 'EUR',
        chargedAmount: 4200,
        chargedCurrency: 'UAH',
        exchangeRate: 42,
        type: 'expense',
        group: { id: 10, name: 'Transport' },
        category: { id: 3, name: 'Fuel' },
        comment: 'gas station',
        transferId: '',
      });
    });

    it('converts transacted_at string to Date', () => {
      const dto = makeTransactionDto({
        transacted_at: '2026-01-01T00:00:00Z',
      });

      expect(mapper.fromTransactionDto(dto).transactedAt).toEqual(
        new Date('2026-01-01T00:00:00Z'),
      );
    });
  });

  describe('fromTransactionDetailsDto', () => {
    it('maps nested dto fields to Transaction model', () => {
      const dto = makeTransactionDetailsDto();
      const result = mapper.fromTransactionDetailsDto(dto);

      expect(result).toEqual({
        id: 1,
        account: { id: 5, name: 'Main' },
        transactedAt: new Date('2026-03-15T10:00:00Z'),
        localOffset: '+02:00',
        transactionAmount: 100,
        transactionCurrency: 'EUR',
        chargedAmount: 4200,
        chargedCurrency: 'UAH',
        exchangeRate: 42,
        type: 'expense',
        group: { id: 10, name: 'Transport' },
        category: { id: 3, name: 'Fuel' },
        comment: 'gas station',
        transferId: '',
      });
    });

    it('calculates exchangeRate from charged_amount / transaction_amount', () => {
      const dto = makeTransactionDetailsDto({
        charged_amount: 500,
        transaction_amount: 10,
      });

      expect(mapper.fromTransactionDetailsDto(dto).exchangeRate).toBe(50);
    });

    it('extracts group from nested category.group', () => {
      const dto = makeTransactionDetailsDto({
        category: {
          id: 7,
          name: 'Groceries',
          group: { id: 20, name: 'Food' },
        },
      });

      const result = mapper.fromTransactionDetailsDto(dto);
      expect(result.group).toEqual({ id: 20, name: 'Food' });
      expect(result.category).toEqual({ id: 7, name: 'Groceries' });
    });
  });

  describe('parseLocalOffset (via fromTransactionDto)', () => {
    const mapOffset = (offset: string) =>
      mapper.fromTransactionDto(makeTransactionDto({ local_offset: offset }))
        .localOffset;

    it('strips trailing :00 from offset', () => {
      expect(mapOffset('+02:00:00')).toBe('+02:00');
    });

    it('preserves offset that already has no trailing :00', () => {
      expect(mapOffset('+05:30')).toBe('+05:30');
    });

    it('adds + sign if missing', () => {
      expect(mapOffset('03:00:00')).toBe('+03:00');
    });

    it('preserves negative offset', () => {
      expect(mapOffset('-05:00:00')).toBe('-05:00');
    });

    it('defaults empty string to +00:00', () => {
      expect(mapOffset('')).toBe('+00:00');
    });

    it('defaults whitespace-only string to +00:00', () => {
      expect(mapOffset('   ')).toBe('+00:00');
    });
  });
});

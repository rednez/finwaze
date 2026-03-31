import { TestBed } from '@angular/core/testing';

import { AccountDto } from '@core/models/accounts';
import { AccountsMapper } from './accounts-mapper';

describe('AccountsMapper', () => {
  let mapper: AccountsMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(AccountsMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromAccountDto', () => {
    it('maps dto fields to Account model', () => {
      const dto: AccountDto = {
        id: 1,
        name: 'Main Wallet',
        currencies: { code: 'USD' },
      };

      const result = mapper.fromAccountDto(dto);

      expect(result).toEqual({
        id: 1,
        name: 'Main Wallet',
        currencyCode: 'USD',
      });
    });

    it('extracts currency code from nested currencies object', () => {
      const dto: AccountDto = {
        id: 42,
        name: 'Euro Account',
        currencies: { code: 'EUR' },
      };

      expect(mapper.fromAccountDto(dto).currencyCode).toBe('EUR');
    });
  });
});

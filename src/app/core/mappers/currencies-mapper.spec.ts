import { TestBed } from '@angular/core/testing';

import { CurrencyDto } from '@core/models/currencies';
import { CurrenciesMapper } from './currencies-mapper';

describe('CurrenciesMapper', () => {
  let mapper: CurrenciesMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    mapper = TestBed.inject(CurrenciesMapper);
  });

  it('should be created', () => {
    expect(mapper).toBeTruthy();
  });

  describe('fromCurrencyDto', () => {
    it('maps dto fields to Currency model', () => {
      const dto: CurrencyDto = {
        id: 1,
        code: 'USD',
        name: 'US Dollar',
        country_name: 'United States',
      };

      expect(mapper.fromCurrencyDto(dto)).toEqual({
        id: 1,
        code: 'USD',
        name: 'US Dollar',
        country: 'United States',
      });
    });

    it('maps country_name to country', () => {
      const dto: CurrencyDto = {
        id: 2,
        code: 'UAH',
        name: 'Ukrainian Hryvnia',
        country_name: 'Ukraine',
      };

      expect(mapper.fromCurrencyDto(dto).country).toBe('Ukraine');
    });
  });
});

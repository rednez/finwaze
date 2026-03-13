import { TestBed } from '@angular/core/testing';

import { CurrenciesRepository } from './currencies-repository';

describe('CurrenciesRepository', () => {
  let service: CurrenciesRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CurrenciesRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

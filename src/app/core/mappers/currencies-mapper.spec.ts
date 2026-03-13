import { TestBed } from '@angular/core/testing';

import { CurrenciesMapper } from './currencies-mapper';

describe('CurrenciesMapper', () => {
  let service: CurrenciesMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CurrenciesMapper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

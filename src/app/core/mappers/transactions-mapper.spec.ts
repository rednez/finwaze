import { TestBed } from '@angular/core/testing';

import { TransactionsMapper } from './transactions-mapper';

describe('TransactionsMapper', () => {
  let service: TransactionsMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(TransactionsMapper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

import { TestBed } from '@angular/core/testing';

import { TransactionsRepository } from './transactions-repository';

describe('TransactionsRepository', () => {
  let service: TransactionsRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(TransactionsRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

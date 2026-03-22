import { TestBed } from '@angular/core/testing';

import { BudgetRepository } from './budget-repository';

describe('BudgetRepository', () => {
  let service: BudgetRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(BudgetRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

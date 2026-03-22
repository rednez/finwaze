import { TestBed } from '@angular/core/testing';

import { BudgetMapper } from './budget-mapper';

describe('BudgetMapper', () => {
  let service: BudgetMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(BudgetMapper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

import { TestBed } from '@angular/core/testing';
import { BudgetState } from './budget-state';

describe('BudgetState', () => {
  let service: BudgetState;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(BudgetState);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

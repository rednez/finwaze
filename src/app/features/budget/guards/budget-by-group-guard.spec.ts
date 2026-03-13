import { TestBed } from '@angular/core/testing';
import { CanActivateFn } from '@angular/router';

import { budgetByGroupGuard } from './budget-by-group-guard';

describe('budgetByGroupGuard', () => {
  const executeGuard: CanActivateFn = (...guardParameters) =>
    TestBed.runInInjectionContext(() => budgetByGroupGuard(...guardParameters));

  beforeEach(() => {
    TestBed.configureTestingModule({});
  });

  it('should be created', () => {
    expect(executeGuard).toBeTruthy();
  });
});

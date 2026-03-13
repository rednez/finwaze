import { TestBed } from '@angular/core/testing';
import { CanMatchFn } from '@angular/router';

import { hasAccountsGuard } from './has-accounts-guard';

describe('hasAccountsGuard', () => {
  const executeGuard: CanMatchFn = (...guardParameters) =>
    TestBed.runInInjectionContext(() => hasAccountsGuard(...guardParameters));

  beforeEach(() => {
    TestBed.configureTestingModule({});
  });

  it('should be created', () => {
    expect(executeGuard).toBeTruthy();
  });
});

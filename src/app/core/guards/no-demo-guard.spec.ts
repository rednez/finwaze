import { TestBed } from '@angular/core/testing';
import { CanActivateFn } from '@angular/router';

import { noDemoGuard } from './no-demo-guard';

describe('noDemoGuard', () => {
  const executeGuard: CanActivateFn = (...guardParameters) =>
    TestBed.runInInjectionContext(() => noDemoGuard(...guardParameters));

  beforeEach(() => {
    TestBed.configureTestingModule({});
  });

  it('should be created', () => {
    expect(executeGuard).toBeTruthy();
  });
});

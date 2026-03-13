import { TestBed } from '@angular/core/testing';
import { ResolveFn } from '@angular/router';

import { mostExpensesResolver } from './most-expenses-resolver';

describe('mostExpensesResolver', () => {
  const executeResolver: ResolveFn<
    {
      id: number;
      name: string;
      currentAmount: number;
      previousPeriodAmount: number;
      currency: string;
    }[]
  > = (...resolverParameters) =>
    TestBed.runInInjectionContext(() =>
      mostExpensesResolver(...resolverParameters),
    );

  beforeEach(() => {
    TestBed.configureTestingModule({});
  });

  it('should be created', () => {
    expect(executeResolver).toBeTruthy();
  });
});

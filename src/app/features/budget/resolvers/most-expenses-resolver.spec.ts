import { TestBed } from '@angular/core/testing';
import { ResolveFn } from '@angular/router';

import { mostExpensesResolver } from './most-expenses-resolver';

describe('mostExpensesResolver', () => {
  const executeResolver: ResolveFn<boolean> = (...resolverParameters) => 
      TestBed.runInInjectionContext(() => mostExpensesResolver(...resolverParameters));

  beforeEach(() => {
    TestBed.configureTestingModule({});
  });

  it('should be created', () => {
    expect(executeResolver).toBeTruthy();
  });
});

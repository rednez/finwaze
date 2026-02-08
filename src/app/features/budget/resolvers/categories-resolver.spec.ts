import { TestBed } from '@angular/core/testing';
import { ResolveFn } from '@angular/router';

import { categoriesResolver } from './categories-resolver';

describe('categoriesResolver', () => {
  const executeResolver: ResolveFn<
    {
      id: number;
      name: string;
      budgetAmount: number;
      spentAmount: number;
      currency: string;
    }[]
  > = (...resolverParameters) =>
    TestBed.runInInjectionContext(() =>
      categoriesResolver(...resolverParameters),
    );

  beforeEach(() => {
    TestBed.configureTestingModule({});
  });

  it('should be created', () => {
    expect(executeResolver).toBeTruthy();
  });
});

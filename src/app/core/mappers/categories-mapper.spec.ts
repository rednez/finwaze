import { TestBed } from '@angular/core/testing';

import { CategoriesMapper } from './categories-mapper';

describe('CategoriesMapper', () => {
  let service: CategoriesMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(CategoriesMapper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

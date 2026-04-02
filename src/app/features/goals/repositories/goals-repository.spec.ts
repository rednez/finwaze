import { TestBed } from '@angular/core/testing';

import { GoalsRepository } from './goals-repository';

describe('GoalsRepository', () => {
  let service: GoalsRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(GoalsRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

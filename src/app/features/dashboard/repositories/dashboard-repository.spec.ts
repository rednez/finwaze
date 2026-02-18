import { TestBed } from '@angular/core/testing';

import { DashboardRepository } from './dashboard-repository';

describe('DashboardRepository', () => {
  let service: DashboardRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(DashboardRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

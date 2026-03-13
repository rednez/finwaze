import { TestBed } from '@angular/core/testing';

import { DashboardMapper } from './dashboard-mapper';

describe('DashboardMapper', () => {
  let service: DashboardMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(DashboardMapper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

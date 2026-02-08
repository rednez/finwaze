import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StatsFilters } from './stats-filters';

describe('StatsFilters', () => {
  let component: StatsFilters;
  let fixture: ComponentFixture<StatsFilters>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [StatsFilters]
    })
    .compileComponents();

    fixture = TestBed.createComponent(StatsFilters);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StatisticsByGroups } from './statistics-by-groups';

describe('StatisticsByGroups', () => {
  let component: StatisticsByGroups;
  let fixture: ComponentFixture<StatisticsByGroups>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [StatisticsByGroups],
    }).compileComponents();

    fixture = TestBed.createComponent(StatisticsByGroups);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

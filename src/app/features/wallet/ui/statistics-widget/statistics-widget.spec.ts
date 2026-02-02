import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StatisticsWidget } from './statistics-widget';

describe('StatisticsWidget', () => {
  let component: StatisticsWidget;
  let fixture: ComponentFixture<StatisticsWidget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [StatisticsWidget]
    })
    .compileComponents();

    fixture = TestBed.createComponent(StatisticsWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

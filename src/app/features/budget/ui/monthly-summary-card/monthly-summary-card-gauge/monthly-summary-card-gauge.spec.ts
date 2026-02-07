import { ComponentFixture, TestBed } from '@angular/core/testing';

import { MonthlySummaryCardGauge } from './monthly-summary-card-gauge';

describe('MonthlySummaryCardGauge', () => {
  let component: MonthlySummaryCardGauge;
  let fixture: ComponentFixture<MonthlySummaryCardGauge>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MonthlySummaryCardGauge],
    }).compileComponents();

    fixture = TestBed.createComponent(MonthlySummaryCardGauge);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('currency', 'USD');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

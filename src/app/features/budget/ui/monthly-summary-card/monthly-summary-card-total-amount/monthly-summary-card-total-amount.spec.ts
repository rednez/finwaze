import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MonthlySummaryCardTotalAmount } from './monthly-summary-card-total-amount';

describe('MonthlySummaryCardTotalAmount', () => {
  let component: MonthlySummaryCardTotalAmount;
  let fixture: ComponentFixture<MonthlySummaryCardTotalAmount>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MonthlySummaryCardTotalAmount],
    }).compileComponents();

    fixture = TestBed.createComponent(MonthlySummaryCardTotalAmount);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('currency', 'USD');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

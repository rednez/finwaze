import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MonthlySummaryCard } from './monthly-summary-card';

describe('MonthlySummaryCard', () => {
  let component: MonthlySummaryCard;
  let fixture: ComponentFixture<MonthlySummaryCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MonthlySummaryCard],
    }).compileComponents();

    fixture = TestBed.createComponent(MonthlySummaryCard);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('currency', 'UAH');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

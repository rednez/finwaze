import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FinancialSummaryCard } from './financial-summary-card';

describe('FinancialSummaryCard', () => {
  let component: FinancialSummaryCard;
  let fixture: ComponentFixture<FinancialSummaryCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FinancialSummaryCard]
    })
    .compileComponents();

    fixture = TestBed.createComponent(FinancialSummaryCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

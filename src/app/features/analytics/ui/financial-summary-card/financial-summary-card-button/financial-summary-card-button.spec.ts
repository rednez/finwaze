import { ComponentFixture, TestBed } from '@angular/core/testing';

import { FinancialSummaryCardButton } from './financial-summary-card-button';

describe('FinancialSummaryCardButton', () => {
  let component: FinancialSummaryCardButton;
  let fixture: ComponentFixture<FinancialSummaryCardButton>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [FinancialSummaryCardButton]
    })
    .compileComponents();

    fixture = TestBed.createComponent(FinancialSummaryCardButton);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

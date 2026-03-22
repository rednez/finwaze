import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetGauge } from './budget-gauge';

describe('BudgetGauge', () => {
  let component: BudgetGauge;
  let fixture: ComponentFixture<BudgetGauge>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetGauge],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetGauge);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

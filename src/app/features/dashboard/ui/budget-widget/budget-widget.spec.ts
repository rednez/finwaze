import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetWidget } from './budget-widget';

describe('BudgetWidget', () => {
  let component: BudgetWidget;
  let fixture: ComponentFixture<BudgetWidget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetWidget]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BudgetWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

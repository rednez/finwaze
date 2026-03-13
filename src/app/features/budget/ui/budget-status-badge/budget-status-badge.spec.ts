import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetStatusBadge } from './budget-status-badge';

describe('BudgetStatusBadge', () => {
  let component: BudgetStatusBadge;
  let fixture: ComponentFixture<BudgetStatusBadge>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetStatusBadge]
    })
    .compileComponents();

    fixture = TestBed.createComponent(BudgetStatusBadge);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

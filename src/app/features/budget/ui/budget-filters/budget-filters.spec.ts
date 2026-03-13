import { ComponentFixture, TestBed } from '@angular/core/testing';
import { BudgetFilters } from './budget-filters';

describe('BudgetFilters', () => {
  let component: BudgetFilters;
  let fixture: ComponentFixture<BudgetFilters>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetFilters],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetFilters);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

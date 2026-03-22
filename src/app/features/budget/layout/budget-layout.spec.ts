import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { BudgetLayout } from './budget-layout';

describe('BudgetLayout', () => {
  let component: BudgetLayout;
  let fixture: ComponentFixture<BudgetLayout>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetLayout],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetLayout);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

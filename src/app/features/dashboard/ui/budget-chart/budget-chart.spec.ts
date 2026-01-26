import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetChart } from './budget-chart';

describe('BudgetChart', () => {
  let component: BudgetChart;
  let fixture: ComponentFixture<BudgetChart>;

  beforeEach(async () => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));

    await TestBed.configureTestingModule({
      imports: [BudgetChart],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetChart);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('categories', []);
    fixture.componentRef.setInput('currency', '$');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

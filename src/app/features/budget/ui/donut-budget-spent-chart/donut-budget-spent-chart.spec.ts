import { ComponentFixture, TestBed } from '@angular/core/testing';
import { DonutBudgetSpentChart } from './donut-budget-spent-chart';

describe('DonutBudgetSpentChart', () => {
  let component: DonutBudgetSpentChart;
  let fixture: ComponentFixture<DonutBudgetSpentChart>;

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
      imports: [DonutBudgetSpentChart],
    }).compileComponents();

    fixture = TestBed.createComponent(DonutBudgetSpentChart);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('currency', 'USD');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

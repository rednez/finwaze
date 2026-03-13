import { ComponentFixture, TestBed } from '@angular/core/testing';
import { BudgetCardChart } from './budget-card-chart';

describe('BudgetCardChart', () => {
  let component: BudgetCardChart;
  let fixture: ComponentFixture<BudgetCardChart>;

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
      imports: [BudgetCardChart],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetCardChart);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('currency', 'USD');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

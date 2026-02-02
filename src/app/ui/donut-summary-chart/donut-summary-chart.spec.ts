import { ComponentFixture, TestBed } from '@angular/core/testing';
import { DonutSummaryChart } from './donut-summary-chart';

describe('DonutSummaryChart', () => {
  let component: DonutSummaryChart;
  let fixture: ComponentFixture<DonutSummaryChart>;

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
      imports: [DonutSummaryChart],
    }).compileComponents();

    fixture = TestBed.createComponent(DonutSummaryChart);
    component = fixture.componentInstance;

    fixture.componentRef.setInput('items', []);
    fixture.componentRef.setInput('currency', 'USD');

    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

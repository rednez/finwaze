import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SavingsOverviewChart } from './savings-overview-chart';

describe('SavingsOverviewChart', () => {
  let component: SavingsOverviewChart;
  let fixture: ComponentFixture<SavingsOverviewChart>;

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
      imports: [SavingsOverviewChart],
    }).compileComponents();

    fixture = TestBed.createComponent(SavingsOverviewChart);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

import { ComponentFixture, TestBed } from '@angular/core/testing';
import { AnalyticStatisticsCard } from './analytic-statistics-card';

describe('AnalyticStatisticsCard', () => {
  window.matchMedia = vi.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  }));

  let component: AnalyticStatisticsCard;
  let fixture: ComponentFixture<AnalyticStatisticsCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [AnalyticStatisticsCard],
    }).compileComponents();

    fixture = TestBed.createComponent(AnalyticStatisticsCard);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

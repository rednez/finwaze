import { ComponentFixture, TestBed } from '@angular/core/testing';
import { SavingsOverviewWidget } from './savings-overview-widget';

describe('SavingsOverviewWidget', () => {
  let component: SavingsOverviewWidget;
  let fixture: ComponentFixture<SavingsOverviewWidget>;

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
      imports: [SavingsOverviewWidget],
    }).compileComponents();

    fixture = TestBed.createComponent(SavingsOverviewWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

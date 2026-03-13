import { ComponentFixture, TestBed } from '@angular/core/testing';

import { StatisticsWidget } from './statistics-widget';

describe('StatisticsWidget', () => {
  window.matchMedia = vi.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  }));

  let component: StatisticsWidget;
  let fixture: ComponentFixture<StatisticsWidget>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [StatisticsWidget],
    }).compileComponents();

    fixture = TestBed.createComponent(StatisticsWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

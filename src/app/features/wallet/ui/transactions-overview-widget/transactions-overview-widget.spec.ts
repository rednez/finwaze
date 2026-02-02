import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TransactionsOverviewWidget } from './transactions-overview-widget';

describe('TransactionsOverviewWidget', () => {
  let component: TransactionsOverviewWidget;
  let fixture: ComponentFixture<TransactionsOverviewWidget>;

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
      imports: [TransactionsOverviewWidget],
    }).compileComponents();

    fixture = TestBed.createComponent(TransactionsOverviewWidget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

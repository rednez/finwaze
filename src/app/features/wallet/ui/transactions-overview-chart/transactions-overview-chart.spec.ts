import { ComponentFixture, TestBed } from '@angular/core/testing';

import { TransactionsOverviewChart } from './transactions-overview-chart';

describe('TransactionsOverviewChart', () => {
  let component: TransactionsOverviewChart;
  let fixture: ComponentFixture<TransactionsOverviewChart>;

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
      imports: [TransactionsOverviewChart],
    }).compileComponents();

    fixture = TestBed.createComponent(TransactionsOverviewChart);

    fixture.componentRef.setInput('labels', []);
    fixture.componentRef.setInput('incomes', []);
    fixture.componentRef.setInput('expenses', []);

    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

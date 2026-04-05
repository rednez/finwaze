import { ComponentFixture, TestBed } from '@angular/core/testing';
import { BudgetCard } from './budget-card';

// eslint-disable-next-line @typescript-eslint/no-empty-function
const noop = () => {};

Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: (query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: noop,
    removeListener: noop,
    addEventListener: noop,
    removeEventListener: noop,
    dispatchEvent: () => false,
  }),
});

describe('BudgetCard', () => {
  let component: BudgetCard;
  let fixture: ComponentFixture<BudgetCard>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [BudgetCard],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetCard);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('currencyCode', 'USD');
    fixture.detectChanges();
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

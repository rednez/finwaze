import { ComponentFixture, TestBed } from '@angular/core/testing';

import { BudgetWidget } from './budget-widget';

describe('BudgetWidget', () => {
  let component: BudgetWidget;
  let fixture: ComponentFixture<BudgetWidget>;

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
      imports: [BudgetWidget],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetWidget);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('currency', 'USD');
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

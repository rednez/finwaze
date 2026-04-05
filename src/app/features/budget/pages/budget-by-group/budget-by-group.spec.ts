import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { BudgetByGroup } from './budget-by-group';

describe('BudgetByGroup', () => {
  let component: BudgetByGroup;
  let fixture: ComponentFixture<BudgetByGroup>;

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
      imports: [BudgetByGroup],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(BudgetByGroup);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

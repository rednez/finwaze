import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Budget } from './budget';

describe('Budget', () => {
  let component: Budget;
  let fixture: ComponentFixture<Budget>;

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
      imports: [Budget],
    }).compileComponents();

    fixture = TestBed.createComponent(Budget);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';

import { Goals } from './goals';

describe('Goals', () => {
  let component: Goals;
  let fixture: ComponentFixture<Goals>;

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
      imports: [Goals],
      providers: [provideRouter([])],
    }).compileComponents();

    fixture = TestBed.createComponent(Goals);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

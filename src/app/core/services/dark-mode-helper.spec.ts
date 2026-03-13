import { TestBed } from '@angular/core/testing';
import { DarkModeHelper } from './dark-mode-helper';

describe('DarkModeHelper', () => {
  let service: DarkModeHelper;

  beforeEach(() => {
    window.matchMedia = vi.fn().mockImplementation((query) => ({
      matches: false,
      media: query,
      onchange: null,
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    }));

    TestBed.configureTestingModule({});
    service = TestBed.inject(DarkModeHelper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

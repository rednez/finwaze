import { TestBed } from '@angular/core/testing';

import { DarkModeHelper } from './dark-mode-helper';

describe('DarkModeHelper', () => {
  let service: DarkModeHelper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(DarkModeHelper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

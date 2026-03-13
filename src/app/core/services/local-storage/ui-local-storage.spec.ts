import { TestBed } from '@angular/core/testing';

import { UiLocalStorage } from './ui-local-storage';

describe('UiLocalStorage', () => {
  let service: UiLocalStorage;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(UiLocalStorage);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

import { TestBed } from '@angular/core/testing';

import { ResponsiveHelper } from './responsive-helper';

describe('ResponsiveHelper', () => {
  let service: ResponsiveHelper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(ResponsiveHelper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

import { TestBed } from '@angular/core/testing';

import { Hhelp } from './hhelp';

describe('Hhelp', () => {
  let service: Hhelp;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Hhelp);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

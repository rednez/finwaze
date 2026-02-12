import { TestBed } from '@angular/core/testing';
import { NavigatorHelper } from './navigator-helper';

describe('NavigatorHelper', () => {
  let service: NavigatorHelper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(NavigatorHelper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

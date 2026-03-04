import { TestBed } from '@angular/core/testing';

import { AccountsLocalStorage } from './accounts-local-storage';

describe('AccountsLocalStorage', () => {
  let service: AccountsLocalStorage;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AccountsLocalStorage);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

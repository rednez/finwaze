import { TestBed } from '@angular/core/testing';

import { AccountsMapper } from './accounts-mapper';

describe('AccountsMapper', () => {
  let service: AccountsMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AccountsMapper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

import { TestBed } from '@angular/core/testing';

import { AccountsRepository } from './accounts-repository';

describe('AccountsRepository', () => {
  let service: AccountsRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(AccountsRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

import { TestBed } from '@angular/core/testing';

import { WalletRepository } from './wallet-repository';

describe('WalletRepository', () => {
  let service: WalletRepository;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(WalletRepository);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

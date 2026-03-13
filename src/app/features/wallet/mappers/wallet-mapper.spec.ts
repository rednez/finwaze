import { TestBed } from '@angular/core/testing';

import { WalletMapper } from './wallet-mapper';

describe('WalletMapper', () => {
  let service: WalletMapper;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(WalletMapper);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

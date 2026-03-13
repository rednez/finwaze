import { Account } from '@core/models/accounts';

export interface RegularAccount extends Account {
  balance: number;
}

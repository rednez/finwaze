import { Injectable } from '@angular/core';
import { RegularAccount } from '../models';

@Injectable({
  providedIn: 'root',
})
export class WalletMapper {
  fromRegularAccountDto(dto: any): RegularAccount {
    return {
      id: dto.id,
      name: dto.name,
      currencyCode: dto.currency_code,
      balance: dto.balance,
    };
  }
}

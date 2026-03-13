import { Injectable } from '@angular/core';
import { Account } from '@core/models/accounts';

@Injectable({
  providedIn: 'root',
})
export class AccountsMapper {
  fromAccountDto(dto: any): Account {
    return {
      id: dto.id,
      name: dto.name,
      currencyCode: dto.currencies.code,
    };
  }
}

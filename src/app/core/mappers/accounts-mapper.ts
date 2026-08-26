import { Service } from '@angular/core';
import { Account, AccountDto } from '@core/models/accounts';

@Service()
export class AccountsMapper {
  fromAccountDto(dto: AccountDto): Account {
    return {
      id: dto.id,
      name: dto.name,
      currencyCode: dto.currencies.code,
    };
  }
}

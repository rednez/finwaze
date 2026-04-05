import { Injectable } from '@angular/core';
import { Currency, CurrencyDto } from '@core/models/currencies';

@Injectable({
  providedIn: 'root',
})
export class CurrenciesMapper {
  fromCurrencyDto(dto: CurrencyDto): Currency {
    return {
      id: dto.id,
      code: dto.code,
      name: dto.name,
      country: dto.country_name,
    };
  }
}

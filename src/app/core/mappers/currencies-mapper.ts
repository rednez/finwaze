import { Injectable } from '@angular/core';
import { Currency } from '@core/models/currencies';

@Injectable({
  providedIn: 'root',
})
export class CurrenciesMapper {
  fromCurrencyDto(dto: any): Currency {
    return {
      code: dto.code,
      name: dto.name,
      country: dto.country_name,
    };
  }
}

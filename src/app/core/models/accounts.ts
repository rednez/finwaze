export interface AccountDto {
  id: number;
  name: string;
  currencies: { code: string };
}

export interface Account {
  id: number;
  name: string;
  currencyCode: string;
}

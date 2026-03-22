import { Injectable } from '@angular/core';

@Injectable({
  providedIn: 'root',
})
export class BudgetService {
  getMostExpenses() {
    return [
      {
        id: 1,
        name: 'Food',
        currentAmount: 1200.4,
        previousPeriodAmount: 1000,
        currency: 'USD',
      },
      {
        id: 2,
        name: 'Medicine',
        currentAmount: 500,
        previousPeriodAmount: 1100,
        currency: 'USD',
      },
      {
        id: 3,
        name: 'Entertainment',
        currentAmount: 500,
        previousPeriodAmount: 800,
        currency: 'USD',
      },
      {
        id: 4,
        name: 'Sport and Movies',
        currentAmount: 450,
        previousPeriodAmount: 1500,
        currency: 'USD',
      },
      {
        id: 5,
        name: 'Other',
        currentAmount: 700,
        previousPeriodAmount: 750,
        currency: 'USD',
      },
      {
        id: 6,
        name: 'Other',
        currentAmount: 300,
        previousPeriodAmount: 290,
        currency: 'USD',
      },
      {
        id: 7,
        name: 'Other',
        currentAmount: 500,
        previousPeriodAmount: 600,
        currency: 'USD',
      },
    ];
  }
}

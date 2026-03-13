import { Injectable } from '@angular/core';
import { map, timer } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class BudgetService {
  getCategories(groupId: number) {
    // TODO: fetch from the server
    return timer(1000).pipe(
      map(() => [
        {
          id: 1,
          name: 'Category 1',
          budgetAmount: 1000,
          spentAmount: 800,
          currency: 'UAH',
        },
        {
          id: 2,
          name: 'Category 2',
          budgetAmount: 500,
          spentAmount: 450,
          currency: 'UAH',
        },
        {
          id: 3,
          name: 'Category 3',
          budgetAmount: 1300,
          spentAmount: 1200.4,
          currency: 'UAH',
        },
        {
          id: 4,
          name: 'Category 4',
          budgetAmount: 1100,
          spentAmount: 450,
          currency: 'UAH',
        },
        {
          id: 5,
          name: 'Category 5',
          budgetAmount: 700,
          spentAmount: 650.45,
          currency: 'UAH',
        },
      ]),
    );
  }

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

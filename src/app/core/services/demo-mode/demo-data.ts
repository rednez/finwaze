import dayjs from 'dayjs';
import { TransactionDto, TransactionType } from '@core/models/transactions';

interface RegularAccountDto {
  id: number;
  name: string;
  currency_id: number;
  currency_code: string;
  balance: number;
  can_delete: boolean;
}

const LOCAL_OFFSET = '+02:00';

// ─── Static seed data ────────────────────────────────────────────────────────

const ACCOUNTS: RegularAccountDto[] = [
  { id: 1, name: 'Main Card',  currency_id: 1, currency_code: 'USD', balance: 3200,  can_delete: false },
  { id: 2, name: 'Cash',       currency_id: 2, currency_code: 'UAH', balance: 18500, can_delete: false },
  { id: 3, name: 'Savings',    currency_id: 3, currency_code: 'EUR', balance: 5800,  can_delete: false },
];

const CURRENCIES = [
  { id: 1, code: 'USD', name: 'US Dollar',          country_name: 'United States' },
  { id: 2, code: 'UAH', name: 'Ukrainian Hryvnia',  country_name: 'Ukraine' },
  { id: 3, code: 'EUR', name: 'Euro',                country_name: 'European Union' },
];

const GROUPS = [
  { id: 1, name: 'Food',           transaction_type: 'expense', is_system: false },
  { id: 2, name: 'Transport',      transaction_type: 'expense', is_system: false },
  { id: 3, name: 'Entertainment',  transaction_type: 'expense', is_system: false },
  { id: 4, name: 'Housing',        transaction_type: 'expense', is_system: false },
  { id: 5, name: 'Salary',         transaction_type: 'income',  is_system: false },
];

const CATEGORIES = [
  { id: 1, group_id: 1, name: 'Groceries' },
  { id: 2, group_id: 1, name: 'Restaurants' },
  { id: 3, group_id: 2, name: 'Taxi' },
  { id: 4, group_id: 2, name: 'Public Transport' },
  { id: 5, group_id: 3, name: 'Cinema' },
  { id: 6, group_id: 3, name: 'Subscriptions' },
  { id: 7, group_id: 4, name: 'Rent' },
  { id: 8, group_id: 5, name: 'Monthly Paycheck' },
];

const SAVINGS_GOALS = [
  {
    id: 101,
    name: 'Emergency Fund',
    currency_code: 'USD',
    target_date: dayjs().add(8, 'month').format('YYYY-MM-DD'),
    status: 'in_progress',
    target_amount: 10000,
    accumulated_amount: 5800,
  },
  {
    id: 102,
    name: 'Vacation',
    currency_code: 'EUR',
    target_date: dayjs().add(4, 'month').format('YYYY-MM-DD'),
    status: 'in_progress',
    target_amount: 2000,
    accumulated_amount: 850,
  },
];

// ─── Transaction template definitions ────────────────────────────────────────

interface TxDef {
  day: number;
  type: TransactionType;
  catId: number;
  groupId: number;
  amt: number; // positive = income, negative = expense
}

const TX_DEFS: TxDef[] = [
  { day: 1,  type: 'income',  catId: 8, groupId: 5, amt: 3200 },
  { day: 3,  type: 'expense', catId: 7, groupId: 4, amt: -1200 },
  { day: 5,  type: 'expense', catId: 1, groupId: 1, amt: -85 },
  { day: 8,  type: 'expense', catId: 3, groupId: 2, amt: -15 },
  { day: 10, type: 'expense', catId: 2, groupId: 1, amt: -45 },
  { day: 12, type: 'expense', catId: 6, groupId: 3, amt: -20 },
  { day: 15, type: 'expense', catId: 1, groupId: 1, amt: -65 },
  { day: 18, type: 'expense', catId: 4, groupId: 2, amt: -5 },
  { day: 20, type: 'expense', catId: 5, groupId: 3, amt: -30 },
  { day: 22, type: 'expense', catId: 1, groupId: 1, amt: -55 },
  { day: 25, type: 'expense', catId: 3, groupId: 2, amt: -18 },
  { day: 28, type: 'expense', catId: 2, groupId: 1, amt: -40 },
];

// ─── Date-relative generators ─────────────────────────────────────────────────

function buildTransactionsForMonth(monthStr: string): TransactionDto[] {
  const month = dayjs(monthStr).startOf('month');
  const today = dayjs();

  if (month.isAfter(today, 'month')) return [];

  const results: TransactionDto[] = [];
  let id = parseInt(month.format('YYYYMM')) * 100;

  for (const def of TX_DEFS) {
    if (def.day > month.daysInMonth()) continue;

    const txDate = month.date(def.day);
    if (month.isSame(today, 'month') && txDate.isAfter(today, 'day')) continue;

    results.push({
      id: id++,
      transacted_at: txDate.toISOString(),
      local_offset: LOCAL_OFFSET,
      transaction_amount: Math.abs(def.amt),
      transaction_currency_code: 'USD',
      account_id: 1,
      account_name: 'Main Card',
      charged_amount: Math.abs(def.amt),
      charged_currency_code: 'USD',
      exchange_rate: 1,
      type: def.type,
      category_id: def.catId,
      category_name: CATEGORIES.find((c) => c.id === def.catId)!.name,
      group_id: def.groupId,
      group_name: GROUPS.find((g) => g.id === def.groupId)!.name,
      comment: '',
      transfer_id: '',
    });
  }

  return results;
}

function buildMonthlyCashFlow(months: number) {
  const result = [];
  for (let i = months - 1; i >= 0; i--) {
    const m = dayjs().subtract(i, 'month').startOf('month');
    const seed = m.month() + 1;
    result.push({
      month: m.toISOString(),
      total_income: 3200,
      total_expense: -(1400 + seed * 30),
    });
  }
  return result;
}

function buildDailyOverview(month: dayjs.Dayjs) {
  const today = dayjs();
  const result = [];
  let running = 25000;

  for (let d = 1; d <= month.daysInMonth(); d++) {
    const day = month.date(d);
    if (day.isAfter(today, 'day')) break;

    const isPayday = d === 1;
    const dailyIncome = isPayday ? 3200 : 0;
    const dailyExpense = isPayday ? 0 : -(d % 3 === 0 ? 85 : d % 5 === 0 ? 45 : 20);
    running += dailyIncome + dailyExpense;

    result.push({
      day: day.format('YYYY-MM-DD'),
      daily_income: dailyIncome,
      daily_expense: dailyExpense,
      running_balance: running,
    });
  }
  return result;
}

function buildDailyCashFlow(month: dayjs.Dayjs) {
  const today = dayjs();
  const result = [];

  for (let d = 1; d <= month.daysInMonth(); d++) {
    const day = month.date(d);
    if (day.isAfter(today, 'day')) break;

    const isPayday = d === 1;
    result.push({
      day: day.format('YYYY-MM-DD'),
      total_income: isPayday ? 3200 : 0,
      total_expense: isPayday ? 0 : -(d % 3 === 0 ? 85 : d % 5 === 0 ? 45 : 20),
    });
  }
  return result;
}

function buildYearlyBudgetsVsExpenses(year: number) {
  const result = [];
  for (let m = 0; m < 12; m++) {
    const month = dayjs().year(year).month(m).startOf('month');
    const seed = m + 1;
    result.push({
      month: month.format('YYYY-MM-DD'),
      budget_amount: 1800,
      expense_amount: -(1400 + seed * 20),
    });
  }
  return result;
}

function buildDetailedBudgets() {
  return CATEGORIES.filter((c) => c.group_id !== 5).map((c) => ({
    category_id: c.id,
    category_name: c.name,
    group_id: c.group_id,
    group_name: GROUPS.find((g) => g.id === c.group_id)!.name,
    planned_amount: 150,
    previous_planned_amount: 140,
    spent_amount: -80,
    previous_spent_amount: -95,
    is_unplanned: false,
  }));
}

function buildSavingsOverview(year: number) {
  const result = [];
  for (let m = 0; m < 12; m++) {
    const month = dayjs().year(year).month(m).startOf('month');
    result.push({
      month: month.format('YYYY-MM-DD'),
      current_year_amount: 200 + m * 30,
      previous_year_amount: 150 + m * 25,
    });
  }
  return result;
}

function buildGroupsWithCategories() {
  return GROUPS.map((g) => ({
    id: g.id,
    name: g.name,
    transaction_type: g.transaction_type,
    categories: CATEGORIES.filter((c) => c.group_id === g.id).map((c) => ({
      id: c.id,
      name: c.name,
      transactions_count: 5,
    })),
  }));
}

// ─── Public dispatch functions ────────────────────────────────────────────────

export function getFakeTableData(table: string): unknown {
  switch (table) {
    case 'accounts':
      return ACCOUNTS.map((a) => ({
        id: a.id,
        name: a.name,
        currencies: { code: a.currency_code },
      }));
    case 'currencies':
      return CURRENCIES;
    case 'categories':
      return CATEGORIES;
    case 'groups':
      return GROUPS;
    case 'transactions':
      return buildTransactionsForMonth(dayjs().startOf('month').format('YYYY-MM-DD'));
    case 'regular_accounts_with_balance':
      return ACCOUNTS;
    case 'groups_with_categories_tx_counts':
      return buildGroupsWithCategories();
    default:
      return [];
  }
}

export function getFakeRpcData(fn: string, params?: Record<string, unknown>): unknown {
  switch (fn) {

    // === TRANSACTIONS ===
    case 'get_filtered_transactions':
      return buildTransactionsForMonth(
        (params?.['p_month'] as string) ?? dayjs().startOf('month').format('YYYY-MM-DD'),
      );

    case 'get_transfer_transactions':
      return [];

    case 'get_recent_transactions':
      return buildTransactionsForMonth(dayjs().startOf('month').format('YYYY-MM-DD'))
        .slice(0, (params?.['p_limit'] as number) ?? 3);

    // === DASHBOARD ===
    case 'get_dashboard_totals':
      return [{
        total_balance: 27500,
        monthly_income: 3200,
        monthly_expense: -1573,
        previous_total_balance: 25900,
        previous_monthly_income: 3200,
        previous_monthly_expense: -1820,
      }];

    case 'get_monthly_charged_cash_flow':
      return buildMonthlyCashFlow((params?.['p_months'] as number) ?? 6);

    case 'get_current_month_budgets_by_category':
      return [
        { category_name: 'Groceries',  total_budget: 250 },
        { category_name: 'Rent',       total_budget: 1200 },
        { category_name: 'Transport',  total_budget: 100 },
      ];

    case 'get_savings_goals':
      return SAVINGS_GOALS;

    // === ANALYTICS ===
    case 'get_analytics_financial_summary':
      return [{
        monthly_income: 3200,
        previous_monthly_income: 3200,
        monthly_expense: -1573,
        previous_monthly_expense: -1820,
        total_balance: 27500,
        previous_total_balance: 25900,
        income_transaction_count: 1,
        expense_transaction_count: 11,
        income_groups_count: 1,
        expense_groups_count: 4,
      }];

    case 'get_daily_financial_overview_for_month': {
      const month = dayjs((params?.['p_month'] as string) ?? dayjs().format('YYYY-MM-DD'));
      return buildDailyOverview(month);
    }

    case 'get_analytics_amounts_by_groups':
      return [
        { group_id: 1, group_name: 'Food',          income_amount: 0,    expense_amount: -245 },
        { group_id: 2, group_name: 'Transport',     income_amount: 0,    expense_amount: -38 },
        { group_id: 3, group_name: 'Entertainment', income_amount: 0,    expense_amount: -50 },
        { group_id: 4, group_name: 'Housing',       income_amount: 0,    expense_amount: -1200 },
        { group_id: 5, group_name: 'Salary',        income_amount: 3200, expense_amount: 0 },
      ];

    case 'get_yearly_budgets_vs_expenses':
      return buildYearlyBudgetsVsExpenses((params?.['p_year'] as number) ?? dayjs().year());

    // === BUDGET ===
    case 'get_monthly_budgets_by_groups':
      return [
        { group_id: 1, group_name: 'Food',          planned_amount: 300,  spent_amount: -245,  is_unplanned: false, categories_count: 2 },
        { group_id: 2, group_name: 'Transport',     planned_amount: 100,  spent_amount: -38,   is_unplanned: false, categories_count: 2 },
        { group_id: 3, group_name: 'Entertainment', planned_amount: 80,   spent_amount: -50,   is_unplanned: false, categories_count: 2 },
        { group_id: 4, group_name: 'Housing',       planned_amount: 1300, spent_amount: -1200, is_unplanned: false, categories_count: 1 },
      ];

    case 'get_monthly_budgets_by_categories': {
      const gid = params?.['p_group_id'] as number;
      return CATEGORIES
        .filter((c) => c.group_id === gid)
        .map((c) => ({
          category_id: c.id,
          category_name: c.name,
          planned_amount: 150,
          spent_amount: -80,
          is_unplanned: false,
        }));
    }

    case 'get_monthly_budget_totals':
    case 'get_monthly_budget_totals_by_group':
      return [{ planned_amount: 1780, spent_amount: -1533 }];

    case 'get_monthly_expenses_by_groups':
      return [
        { group_id: 1, group_name: 'Food',          selected_month_amount: -245,  previous_month_amount: -280 },
        { group_id: 2, group_name: 'Transport',     selected_month_amount: -38,   previous_month_amount: -55 },
        { group_id: 3, group_name: 'Entertainment', selected_month_amount: -50,   previous_month_amount: -70 },
        { group_id: 4, group_name: 'Housing',       selected_month_amount: -1200, previous_month_amount: -1200 },
      ];

    case 'get_monthly_expenses_by_categories': {
      const gid = params?.['p_group_id'] as number;
      return CATEGORIES
        .filter((c) => c.group_id === gid)
        .map((c) => ({
          category_id: c.id,
          category_name: c.name,
          selected_month_amount: -80,
          previous_month_amount: -90,
        }));
    }

    case 'get_monthly_budgets_detailed':
    case 'generate_monthly_budgets_from_previous':
      return buildDetailedBudgets();

    case 'get_category_budget_stats':
      return [{ previous_planned_amount: 150, spent_amount: -80, previous_spent_amount: -90 }];

    // === WALLET ===
    case 'get_regular_account_with_balance': {
      const id = params?.['p_account_id'] as number;
      return ACCOUNTS.filter((a) => a.id === id);
    }

    case 'get_daily_transactions_cash_flow_for_month': {
      const month = dayjs((params?.['p_month'] as string) ?? dayjs().format('YYYY-MM-DD'));
      return buildDailyCashFlow(month);
    }

    case 'get_monthly_transaction_amounts_by_group':
      return [
        { group_name: 'Food',          total_expense: -245,  total_income: 0 },
        { group_name: 'Transport',     total_expense: -38,   total_income: 0 },
        { group_name: 'Entertainment', total_expense: -50,   total_income: 0 },
        { group_name: 'Housing',       total_expense: -1200, total_income: 0 },
        { group_name: 'Salary',        total_expense: 0,     total_income: 3200 },
      ];

    // === GOALS ===
    case 'get_monthly_savings_overview':
      return buildSavingsOverview((params?.['p_year'] as number) ?? dayjs().year());

    // === WRITE RPCs — silent no-op ===
    case 'create_savings_goal':
      // Return a fake account ID so the store can navigate to the new goal page
      return 9999;

    case 'adjust_account_balance':
    case 'make_transfer':
    case 'upsert_monthly_budgets':
    case 'update_savings_goal':
    case 'cancel_savings_goal':
    case 'delete_savings_goal':
      return null;

    default:
      return [];
  }
}

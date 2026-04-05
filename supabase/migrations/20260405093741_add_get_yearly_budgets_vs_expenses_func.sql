set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_yearly_budgets_vs_expenses(p_year integer, p_currency_code text)
 RETURNS TABLE(month date, budget_amount numeric, expense_amount numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  months AS (
    SELECT generate_series(
      make_date(p_year, 1, 1),
      make_date(p_year, 12, 1),
      '1 month'::INTERVAL
    )::DATE AS month
  ),
  budget_totals AS (
    SELECT
      date_trunc('month', mb.budget_month::TIMESTAMP)::DATE AS month,
      SUM(mb.planned_amount)                                AS budget_amount
    FROM public.monthly_budgets mb
    JOIN public.categories cat ON cat.id  = mb.category_id
    JOIN public.groups      g   ON g.id   = cat.group_id
    JOIN public.currencies  cur ON cur.id = mb.currency_id
    WHERE cur.code       = p_currency_code
      AND g.is_system    = false
      AND mb.budget_month >= make_date(p_year, 1, 1)
      AND mb.budget_month <  make_date(p_year + 1, 1, 1)
    GROUP BY date_trunc('month', mb.budget_month::TIMESTAMP)::DATE
  ),
  expense_totals AS (
    SELECT
      date_trunc('month', (t.transacted_at + t.local_offset))::DATE AS month,
      SUM(ABS(t.charged_amount))                                     AS expense_amount
    FROM public.transactions t
    JOIN public.accounts   a   ON a.id   = t.account_id
    JOIN public.currencies cur ON cur.id = a.currency_id
    WHERE cur.code = p_currency_code
      AND t.type NOT IN (
            'transfer'::public.transaction_type,
            'internal'::public.transaction_type
          )
      AND t.charged_amount < 0
      AND (t.transacted_at + t.local_offset) >= make_date(p_year, 1, 1)::TIMESTAMP
      AND (t.transacted_at + t.local_offset) <  make_date(p_year + 1, 1, 1)::TIMESTAMP
    GROUP BY date_trunc('month', (t.transacted_at + t.local_offset))::DATE
  )
SELECT
  m.month,
  COALESCE(bt.budget_amount,  0) AS budget_amount,
  COALESCE(et.expense_amount, 0) AS expense_amount
FROM months           m
LEFT JOIN budget_totals  bt ON bt.month = m.month
LEFT JOIN expense_totals et ON et.month = m.month
ORDER BY m.month;
$function$
;



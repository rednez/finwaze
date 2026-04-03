set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_monthly_savings_overview(
  p_year          integer,
  p_currency_code text
)
RETURNS TABLE(
  month                date,
  current_year_amount  numeric,
  previous_year_amount numeric
)
LANGUAGE sql
STABLE
SET search_path TO ''
AS $function$
WITH
  months AS (
    SELECT gs::date AS month
    FROM generate_series(
      make_date(p_year, 1, 1),
      make_date(p_year, 12, 1),
      interval '1 month'
    ) AS gs
  ),
  savings_accounts AS (
    SELECT acc.id AS account_id
    FROM public.accounts acc
    JOIN public.currencies cur ON cur.id = acc.currency_id
    WHERE acc.type = 'savings_goal'::public.account_type
      AND cur.code  = p_currency_code
  ),
  current_year AS (
    SELECT
      date_trunc('month', (t.transacted_at + t.local_offset))::date AS month,
      SUM(t.charged_amount)                                          AS amount
    FROM public.transactions t
    JOIN savings_accounts sa ON sa.account_id = t.account_id
    WHERE (t.transacted_at + t.local_offset) >= make_date(p_year, 1, 1)::timestamp
      AND (t.transacted_at + t.local_offset) <  make_date(p_year + 1, 1, 1)::timestamp
    GROUP BY date_trunc('month', (t.transacted_at + t.local_offset))
  ),
  previous_year AS (
    SELECT
      (date_trunc('month', (t.transacted_at + t.local_offset))
        + interval '1 year')::date                                   AS month,
      SUM(t.charged_amount)                                          AS amount
    FROM public.transactions t
    JOIN savings_accounts sa ON sa.account_id = t.account_id
    WHERE (t.transacted_at + t.local_offset) >= make_date(p_year - 1, 1, 1)::timestamp
      AND (t.transacted_at + t.local_offset) <  make_date(p_year, 1, 1)::timestamp
    GROUP BY date_trunc('month', (t.transacted_at + t.local_offset))
  )
SELECT
  m.month,
  COALESCE(cy.amount, 0) AS current_year_amount,
  COALESCE(py.amount, 0) AS previous_year_amount
FROM months          m
LEFT JOIN current_year  cy ON cy.month = m.month
LEFT JOIN previous_year py ON py.month = m.month
ORDER BY m.month;
$function$;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_daily_financial_overview_for_month(p_month date, p_currency_code text, p_account_ids bigint[] DEFAULT NULL::bigint[])
 RETURNS TABLE(day date, daily_income numeric, daily_expense numeric, running_balance numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  currency AS (
    SELECT id FROM public.currencies WHERE code = p_currency_code
  ),
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS ts
  ),
  month_end AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) + INTERVAL '1 month' AS ts
  ),
  days AS (
    SELECT gs::date AS day
    FROM generate_series(
      (SELECT ts FROM month_start)::date,
      ((SELECT ts FROM month_end) - INTERVAL '1 day')::date,
      INTERVAL '1 day'
    ) AS gs
  ),
  balance_before AS (
    SELECT COALESCE(SUM(t.charged_amount), 0) AS balance
    FROM public.transactions t
    JOIN currency c ON c.id = t.charged_currency_id
    WHERE (t.transacted_at + t.local_offset) < (SELECT ts FROM month_start)
      AND (
        p_account_ids IS NULL
        OR cardinality(p_account_ids) = 0
        OR t.account_id = ANY(p_account_ids)
      )
  ),
  daily_agg AS (
    SELECT
      (t.transacted_at + t.local_offset)::date AS day,
      COALESCE(SUM(t.charged_amount)
        FILTER (WHERE t.charged_amount > 0
          AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)), 0) AS daily_income,
      COALESCE(ABS(SUM(t.charged_amount)
        FILTER (WHERE t.charged_amount < 0
          AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type))), 0) AS daily_expense,
      COALESCE(SUM(t.charged_amount), 0) AS daily_net
    FROM public.transactions t
    JOIN currency c ON c.id = t.charged_currency_id
    WHERE (t.transacted_at + t.local_offset) >= (SELECT ts FROM month_start)
      AND (t.transacted_at + t.local_offset) <  (SELECT ts FROM month_end)
      AND (
        p_account_ids IS NULL
        OR cardinality(p_account_ids) = 0
        OR t.account_id = ANY(p_account_ids)
      )
    GROUP BY (t.transacted_at + t.local_offset)::date
  ),
  joined AS (
    SELECT
      d.day,
      COALESCE(a.daily_income,  0) AS daily_income,
      COALESCE(a.daily_expense, 0) AS daily_expense,
      COALESCE(a.daily_net,     0) AS daily_net
    FROM days d
    LEFT JOIN daily_agg a ON a.day = d.day
  )
SELECT
  j.day,
  j.daily_income,
  j.daily_expense,
  (SELECT balance FROM balance_before)
    + SUM(j.daily_net) OVER (ORDER BY j.day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    AS running_balance
FROM joined j
ORDER BY j.day;
$function$
;



drop function if exists "public"."get_monthly_cash_flow"(p_currency_code text, p_months integer);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_daily_transactions_cash_flow_for_month(p_currency_code text, p_month date)
 RETURNS TABLE(day date, total_income numeric, total_expense numeric)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
WITH
  currency AS (
    SELECT id
    FROM public.currencies
    WHERE code = p_currency_code
  ),
  days AS (
    SELECT gs::date AS day
    FROM generate_series(
      date_trunc('month', p_month::timestamp)::date,
      (date_trunc('month', p_month::timestamp) + interval '1 month' - interval '1 day')::date,
      interval '1 day'
    ) AS gs
  ),
  adjusted AS (
    SELECT
      (t.transacted_at + t.local_offset) AS adjusted_at,
      t.transaction_amount
    FROM public.transactions t
    JOIN currency c ON c.id = t.transaction_currency_id
    WHERE t.type NOT IN ('transfer', 'internal')
      AND (t.transacted_at + t.local_offset) >= date_trunc('month', p_month::timestamp)
      AND (t.transacted_at + t.local_offset) <  date_trunc('month', p_month::timestamp) + interval '1 month'
  ),
  aggregated AS (
    SELECT
      adjusted_at::date AS day,
      SUM(CASE WHEN transaction_amount > 0 THEN transaction_amount ELSE 0 END) AS total_income,
      SUM(CASE WHEN transaction_amount < 0 THEN transaction_amount ELSE 0 END) AS total_expense
    FROM adjusted
    GROUP BY adjusted_at::date
  )
SELECT
  d.day,
  COALESCE(a.total_income,  0) AS total_income,
  COALESCE(a.total_expense, 0) AS total_expense
FROM days d
LEFT JOIN aggregated a ON a.day = d.day
ORDER BY d.day;
$function$
;

CREATE OR REPLACE FUNCTION public.get_monthly_charged_cash_flow(p_currency_code text, p_months integer DEFAULT 6)
 RETURNS TABLE(month timestamp with time zone, total_income numeric, total_expense numeric)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
  select
    date_trunc('month', (t.transacted_at + t.local_offset)) as month,
    sum(case when t.charged_amount > 0 then t.charged_amount else 0 end) as total_income,
    sum(case when t.charged_amount < 0 then t.charged_amount else 0 end) as total_expense
  from public.transactions t
  join public.currencies c
    on c.id = t.charged_currency_id
  where c.code = p_currency_code
    and t.type <> 'transfer'
    and (t.transacted_at + t.local_offset) >= date_trunc('month', now()) 
        - make_interval(months => p_months - 1)
  group by date_trunc('month', (t.transacted_at + t.local_offset))
  order by month;
$function$
;



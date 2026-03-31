set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_category_budget_stats(p_month date, p_currency_code text, p_category_id bigint)
 RETURNS TABLE(previous_planned_amount numeric, spent_amount numeric, previous_spent_amount numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  month_start AS (
    SELECT
      date_trunc('month', p_month::TIMESTAMP)                      AS val,
      date_trunc('month', p_month::TIMESTAMP) - INTERVAL '1 month' AS prev_val
  ),

  prev_budget AS (
    SELECT COALESCE(SUM(mb.planned_amount), 0) AS amount
    FROM public.monthly_budgets mb
    JOIN public.currencies cur ON cur.id = mb.currency_id
    CROSS JOIN month_start ms
    WHERE cur.code        = p_currency_code
      AND mb.budget_month = ms.prev_val::DATE
      AND mb.category_id  = p_category_id
  ),

  cur_spending AS (
    SELECT COALESCE(ABS(SUM(t.transaction_amount)), 0) AS amount
    FROM public.transactions t
    JOIN public.currencies cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start ms
    WHERE cur.code      = p_currency_code
      AND t.type        = 'expense'::public.transaction_type
      AND t.category_id = p_category_id
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  ),

  prev_spending AS (
    SELECT COALESCE(ABS(SUM(t.transaction_amount)), 0) AS amount
    FROM public.transactions t
    JOIN public.currencies cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start ms
    WHERE cur.code      = p_currency_code
      AND t.type        = 'expense'::public.transaction_type
      AND t.category_id = p_category_id
      AND (t.transacted_at + t.local_offset) >= ms.prev_val
      AND (t.transacted_at + t.local_offset) <  ms.val
  )

SELECT
  pb.amount AS previous_planned_amount,
  cs.amount AS spent_amount,
  ps.amount AS previous_spent_amount
FROM prev_budget pb, cur_spending cs, prev_spending ps;
$function$
;



set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_monthly_budget_totals(p_month date, p_currency_code text)
 RETURNS TABLE(planned_amount numeric, spent_amount numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  budgets AS (
    SELECT SUM(mb.planned_amount) AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories      cat ON cat.id  = mb.category_id
    JOIN public.groups          g   ON g.id    = cat.group_id
    JOIN public.currencies      cur ON cur.id  = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND g.is_system     = false
  ),
  spending AS (
    SELECT -SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code   = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  )
SELECT
  COALESCE(b.planned_amount, 0) AS planned_amount,
  COALESCE(s.spent_amount,   0) AS spent_amount
FROM budgets b, spending s;
$function$
;



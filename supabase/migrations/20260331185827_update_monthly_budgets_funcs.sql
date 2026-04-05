set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.generate_monthly_budgets_from_previous(p_month date, p_currency_code text)
 RETURNS TABLE(category_id bigint, category_name text, group_id bigint, group_name text, planned_amount numeric, previous_planned_amount numeric, spent_amount numeric, previous_spent_amount numeric, is_unplanned boolean)
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

  -- Budgets for the previous month
  prev_budgets AS (
    SELECT
      cat.id                   AS category_id,
      cat.name                 AS category_name,
      g.id                     AS group_id,
      g.name                   AS group_name,
      SUM(mb.planned_amount)   AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories cat ON cat.id  = mb.category_id
    JOIN public.groups     g   ON g.id    = cat.group_id
    JOIN public.currencies cur ON cur.id  = mb.currency_id
    CROSS JOIN month_start ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.prev_val::DATE
      AND g.is_system     = false
    GROUP BY cat.id, cat.name, g.id, g.name
  ),

  -- Actual spending for the previous month (as positive numbers)
  prev_spending AS (
    SELECT
      cat.id                             AS category_id,
      cat.name                           AS category_name,
      g.id                               AS group_id,
      g.name                             AS group_name,
      ABS(SUM(t.transaction_amount))     AS spent_amount
    FROM public.transactions t
    JOIN public.categories  cat ON cat.id = t.category_id
    JOIN public.groups      g   ON g.id   = cat.group_id
    JOIN public.currencies  cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start  ms
    WHERE cur.code    = p_currency_code
      AND t.type      = 'expense'::public.transaction_type
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.prev_val
      AND (t.transacted_at + t.local_offset) <  ms.val
    GROUP BY cat.id, cat.name, g.id, g.name
  ),

  -- Actual spending for the selected month (as positive numbers)
  spending AS (
    SELECT
      cat.id                             AS category_id,
      cat.name                           AS category_name,
      g.id                               AS group_id,
      g.name                             AS group_name,
      ABS(SUM(t.transaction_amount))     AS spent_amount
    FROM public.transactions t
    JOIN public.categories  cat ON cat.id = t.category_id
    JOIN public.groups      g   ON g.id   = cat.group_id
    JOIN public.currencies  cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start  ms
    WHERE cur.code    = p_currency_code
      AND t.type      = 'expense'::public.transaction_type
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY cat.id, cat.name, g.id, g.name
  ),

  combined AS (
    SELECT
      COALESCE(pb.category_id,   ps.category_id,   s.category_id)   AS category_id,
      COALESCE(pb.category_name, ps.category_name, s.category_name) AS category_name,
      COALESCE(pb.group_id,      ps.group_id,      s.group_id)      AS group_id,
      COALESCE(pb.group_name,    ps.group_name,    s.group_name)    AS group_name,
      COALESCE(
        NULLIF(pb.planned_amount, 0),
        NULLIF(ps.spent_amount, 0),
        s.spent_amount,
        0
      )                                                              AS planned_amount,
      COALESCE(pb.planned_amount, 0)                                 AS previous_planned_amount,
      COALESCE(s.spent_amount, 0)                                    AS spent_amount,
      COALESCE(ps.spent_amount, 0)                                   AS previous_spent_amount
    FROM prev_budgets pb
    FULL OUTER JOIN prev_spending ps ON ps.category_id = pb.category_id
    FULL OUTER JOIN spending      s  ON s.category_id  = COALESCE(pb.category_id, ps.category_id)
  )

SELECT
  category_id,
  category_name,
  group_id,
  group_name,
  planned_amount,
  previous_planned_amount,
  spent_amount,
  previous_spent_amount,
  false AS is_unplanned
FROM combined
WHERE planned_amount > 0
ORDER BY
  planned_amount DESC,
  group_name,
  category_name;
$function$
;



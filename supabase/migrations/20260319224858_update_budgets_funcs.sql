set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_monthly_budgets_by_categories(p_month date, p_currency_code text, p_group_id bigint)
 RETURNS TABLE(category_id bigint, category_name text, planned_amount numeric, spent_amount numeric, is_unplanned boolean)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  budgets AS (
    SELECT
      cat.id                 AS category_id,
      cat.name               AS category_name,
      SUM(mb.planned_amount) AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories      cat ON cat.id = mb.category_id
    JOIN public.currencies      cur ON cur.id = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND cat.group_id    = p_group_id
    GROUP BY cat.id, cat.name
  ),
  spending AS (
    SELECT
      cat.id                    AS category_id,
      cat.name                  AS category_name,
      SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code   = p_currency_code
      AND t.type     = 'expense'::public.transaction_type
      AND cat.group_id = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY cat.id, cat.name
  )
SELECT
  COALESCE(b.category_id,   s.category_id)   AS category_id,
  COALESCE(b.category_name, s.category_name) AS category_name,
  COALESCE(b.planned_amount, 0)              AS planned_amount,
  COALESCE(s.spent_amount,   0)              AS spent_amount,
  (b.category_id IS NULL)                    AS is_unplanned
FROM budgets  b
FULL OUTER JOIN spending s ON s.category_id = b.category_id
ORDER BY b.planned_amount DESC NULLS LAST, COALESCE(b.category_name, s.category_name);
$function$
;

CREATE OR REPLACE FUNCTION public.get_monthly_budgets_by_groups(p_month date, p_currency_code text)
 RETURNS TABLE(group_id bigint, group_name text, planned_amount numeric, spent_amount numeric, categories_count bigint, is_unplanned boolean)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  budgets AS (
    SELECT
      g.id                           AS group_id,
      g.name                         AS group_name,
      SUM(mb.planned_amount)         AS planned_amount,
      COUNT(DISTINCT mb.category_id) AS categories_count
    FROM public.monthly_budgets mb
    JOIN public.categories      cat ON cat.id       = mb.category_id
    JOIN public.groups          g   ON g.id         = cat.group_id
    JOIN public.currencies      cur ON cur.id        = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND g.is_system     = false
    GROUP BY g.id, g.name
  ),
  spending AS (
    SELECT
      g.id                      AS group_id,
      g.name                    AS group_name,
      SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code  = p_currency_code
      AND t.type    = 'expense'::public.transaction_type
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY g.id, g.name
  )
SELECT
  COALESCE(b.group_id,   s.group_id)   AS group_id,
  COALESCE(b.group_name, s.group_name) AS group_name,
  COALESCE(b.planned_amount,   0)      AS planned_amount,
  COALESCE(s.spent_amount,     0)      AS spent_amount,
  COALESCE(b.categories_count, 0)      AS categories_count,
  (b.group_id IS NULL)                 AS is_unplanned
FROM budgets  b
FULL OUTER JOIN spending s ON s.group_id = b.group_id
ORDER BY b.planned_amount DESC NULLS LAST, COALESCE(b.group_name, s.group_name);
$function$
;



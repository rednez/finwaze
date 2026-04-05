drop function if exists "public"."get_monthly_expenses_by_group"(p_month date, p_currency_code text);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_monthly_budget_totals_by_group(p_month date, p_currency_code text, p_group_id bigint)
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
    JOIN public.currencies      cur ON cur.id  = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND cat.group_id    = p_group_id
  ),
  spending AS (
    SELECT -SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code   = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND cat.group_id = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  )
SELECT
  COALESCE(b.planned_amount, 0) AS planned_amount,
  COALESCE(s.spent_amount,   0) AS spent_amount
FROM budgets b, spending s;
$function$
;

CREATE OR REPLACE FUNCTION public.get_monthly_expenses_by_categories(p_month date, p_currency_code text, p_group_id bigint)
 RETURNS TABLE(category_id bigint, category_name text, selected_month_amount numeric, previous_month_amount numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  selected_month AS (
    SELECT
      cat.id                      AS category_id,
      cat.name                    AS category_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND cat.group_id           = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY cat.id, cat.name
  ),
  previous_month AS (
    SELECT
      cat.id                      AS category_id,
      cat.name                    AS category_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND cat.group_id           = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val - INTERVAL '1 month'
      AND (t.transacted_at + t.local_offset) <  ms.val
    GROUP BY cat.id, cat.name
  )
SELECT
  COALESCE(s.category_id,   p.category_id)   AS category_id,
  COALESCE(s.category_name, p.category_name) AS category_name,
  COALESCE(s.amount, 0)                      AS selected_month_amount,
  COALESCE(p.amount, 0)                      AS previous_month_amount
FROM selected_month s
LEFT JOIN previous_month p ON p.category_id = s.category_id
ORDER BY selected_month_amount DESC, s.category_name;
$function$
;

CREATE OR REPLACE FUNCTION public.get_monthly_expenses_by_groups(p_month date, p_currency_code text)
 RETURNS TABLE(group_id bigint, group_name text, selected_month_amount numeric, previous_month_amount numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  selected_month AS (
    SELECT
      g.id                        AS group_id,
      g.name                      AS group_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND g.is_system          = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY g.id, g.name
  ),
  previous_month AS (
    SELECT
      g.id                        AS group_id,
      g.name                      AS group_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND g.is_system          = false
      AND (t.transacted_at + t.local_offset) >= ms.val - INTERVAL '1 month'
      AND (t.transacted_at + t.local_offset) <  ms.val
    GROUP BY g.id, g.name
  )
SELECT
  COALESCE(s.group_id,   p.group_id)   AS group_id,
  COALESCE(s.group_name, p.group_name) AS group_name,
  COALESCE(s.amount, 0)                AS selected_month_amount,
  COALESCE(p.amount, 0)                AS previous_month_amount
FROM selected_month s
LEFT JOIN previous_month p ON p.group_id = s.group_id
ORDER BY selected_month_amount DESC, s.group_name;
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
      SUM(mb.planned_amount)         AS planned_amount
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
  ),
  categories_count AS (
    SELECT
      cat.group_id,
      COUNT(DISTINCT combined.category_id) AS categories_count
    FROM (
      SELECT mb.category_id
      FROM public.monthly_budgets mb
      JOIN public.categories cat ON cat.id  = mb.category_id
      JOIN public.groups     g   ON g.id    = cat.group_id
      JOIN public.currencies cur ON cur.id  = mb.currency_id
      CROSS JOIN month_start ms
      WHERE cur.code       = p_currency_code
        AND mb.budget_month = ms.val::DATE
        AND g.is_system     = false

      UNION

      SELECT t.category_id
      FROM public.transactions t
      JOIN public.categories cat ON cat.id = t.category_id
      JOIN public.groups     g   ON g.id   = cat.group_id
      JOIN public.currencies cur ON cur.id = t.transaction_currency_id
      CROSS JOIN month_start ms
      WHERE cur.code  = p_currency_code
        AND t.type    = 'expense'::public.transaction_type
        AND g.is_system = false
        AND (t.transacted_at + t.local_offset) >= ms.val
        AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    ) AS combined(category_id)
    JOIN public.categories cat ON cat.id = combined.category_id
    GROUP BY cat.group_id
  )
SELECT
  COALESCE(b.group_id,   s.group_id)    AS group_id,
  COALESCE(b.group_name, s.group_name)  AS group_name,
  COALESCE(b.planned_amount,   0)       AS planned_amount,
  COALESCE(s.spent_amount,     0)       AS spent_amount,
  COALESCE(cc.categories_count, 0)      AS categories_count,
  (b.group_id IS NULL)                  AS is_unplanned
FROM budgets  b
FULL OUTER JOIN spending s ON s.group_id = b.group_id
LEFT JOIN categories_count cc ON cc.group_id = COALESCE(b.group_id, s.group_id)
ORDER BY b.planned_amount DESC NULLS LAST, COALESCE(b.group_name, s.group_name);
$function$
;



CREATE OR REPLACE FUNCTION public.get_monthly_budgets_by_group(
  p_month         DATE,
  p_currency_code TEXT
)
RETURNS TABLE (
  group_id         BIGINT,
  group_name       TEXT,
  planned_amount   NUMERIC,
  spent_amount     NUMERIC,
  categories_count BIGINT,
  is_unplanned     BOOLEAN
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
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
$$;
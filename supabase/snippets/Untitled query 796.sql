CREATE OR REPLACE FUNCTION public.get_monthly_expenses_by_groups(
  p_month         DATE,
  p_currency_code TEXT
)
RETURNS TABLE (
  group_id                BIGINT,
  group_name              TEXT,
  selected_month_amount   NUMERIC,
  previous_month_amount   NUMERIC
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
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
$$;
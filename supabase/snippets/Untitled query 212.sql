CREATE OR REPLACE FUNCTION get_monthly_transaction_amounts_by_group(
  p_month          DATE,
  p_currency_code  TEXT
)
RETURNS TABLE (
  group_id      BIGINT,
  group_name    TEXT,
  total_income  NUMERIC,
  total_expense NUMERIC
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
  SELECT
    g.id                                                                          AS group_id,
    g.name                                                                        AS group_name,
    COALESCE(SUM(t.transaction_amount) FILTER (WHERE t.type = 'income'), 0)      AS total_income,
    COALESCE(SUM(t.transaction_amount) FILTER (WHERE t.type = 'expense'), 0)     AS total_expense
  FROM public.transactions  t
  JOIN public.categories    cat ON cat.id = t.category_id
  JOIN public.groups        g   ON g.id   = cat.group_id
  JOIN public.currencies    c   ON c.id   = t.transaction_currency_id
  WHERE c.code  = p_currency_code
    AND t.type IN ('income'::public.transaction_type, 'expense'::public.transaction_type)
    AND (t.transacted_at + t.local_offset) >= date_trunc('month', p_month::TIMESTAMP)
    AND (t.transacted_at + t.local_offset) <  date_trunc('month', p_month::TIMESTAMP)
                                               + INTERVAL '1 month'
  GROUP BY g.id, g.name
  ORDER BY ABS(SUM(t.transaction_amount)) DESC, g.name;
$$;
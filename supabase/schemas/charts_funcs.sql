CREATE OR REPLACE FUNCTION get_dashboard_totals (p_currency_code TEXT) returns TABLE (
  total_balance NUMERIC,
  monthly_income NUMERIC,
  monthly_expense NUMERIC,
  previous_total_balance NUMERIC,
  previous_monthly_income NUMERIC,
  previous_monthly_expense NUMERIC
) language plpgsql
SET
  search_path = '' AS $$
declare
    v_currency_id bigint;
begin
    select id into v_currency_id
    from public.currencies
    where code = p_currency_code;

    return query
    select
        -- BALANCE (entire period)
        coalesce(sum(t.charged_amount), 0) as total_balance,

        -- INCOME (current month)
        coalesce(sum(
            case
                when t.charged_amount > 0
                 and (t.transacted_at + t.local_offset) >= date_trunc('month', now())
                 and (t.transacted_at + t.local_offset) < date_trunc('month', now()) + interval '1 month'
                then t.charged_amount
            end
        ), 0) as monthly_income,

        -- EXPENSE (current month)
        coalesce(sum(
            case
                when t.charged_amount < 0
                 and (t.transacted_at + t.local_offset) >= date_trunc('month', now())
                 and (t.transacted_at + t.local_offset) < date_trunc('month', now()) + interval '1 month'
                then t.charged_amount
            end
        ), 0) as monthly_expense,


        -- BALANCE (up to previous month end)
        coalesce(sum(
            case
                when (t.transacted_at + t.local_offset) < date_trunc('month', now())
                then t.charged_amount
            end
        ), 0) as previous_total_balance,

        -- INCOME (previous month)
        coalesce(sum(
            case
                when t.charged_amount > 0
                 and (t.transacted_at + t.local_offset) >= date_trunc('month', now()) - interval '1 month'
                 and (t.transacted_at + t.local_offset) < date_trunc('month', now())
                then t.charged_amount
            end
        ), 0) as previous_monthly_income,

        -- EXPENSE (previous month)
        coalesce(sum(
            case
                when t.charged_amount < 0
                 and (t.transacted_at + t.local_offset) >= date_trunc('month', now()) - interval '1 month'
                 and (t.transacted_at + t.local_offset) < date_trunc('month', now())
                then t.charged_amount
            end
        ), 0) as previous_monthly_expense

    from public.transactions t
    where t.charged_currency_id = v_currency_id
      and t.type <> 'transfer' and t.type <> 'internal';
end;
$$;

CREATE OR REPLACE FUNCTION get_monthly_charged_cash_flow (p_currency_code TEXT, p_months INTEGER DEFAULT 6) returns TABLE (
  MONTH TIMESTAMP WITH TIME ZONE,
  total_income NUMERIC,
  total_expense NUMERIC
) language sql
SET
  search_path = '' AS $$
  select
    date_trunc('month', (t.transacted_at + t.local_offset)) as month,
    sum(case when t.charged_amount > 0 then t.charged_amount else 0 end) as total_income,
    sum(case when t.charged_amount < 0 then t.charged_amount else 0 end) as total_expense
  from public.transactions t
  join public.currencies c
    on c.id = t.charged_currency_id
  where c.code = p_currency_code
    and t.type <> 'transfer' and t.type <> 'internal'
    and (t.transacted_at + t.local_offset) >= date_trunc('month', now()) 
        - make_interval(months => p_months - 1)
  group by date_trunc('month', (t.transacted_at + t.local_offset))
  order by month;
$$;

CREATE OR REPLACE FUNCTION get_daily_transactions_cash_flow_for_month(
  p_currency_code TEXT,
  p_month DATE
)
RETURNS TABLE (
  day DATE,
  total_income NUMERIC,
  total_expense NUMERIC
)
LANGUAGE sql
SET search_path = ''
AS $$
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
$$;

CREATE OR REPLACE FUNCTION get_monthly_transaction_amounts_by_group (p_month DATE, p_currency_code TEXT) RETURNS TABLE (
  group_id BIGINT,
  group_name TEXT,
  total_income NUMERIC,
  total_expense NUMERIC
) LANGUAGE sql STABLE
SET
  search_path = '' AS $$
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
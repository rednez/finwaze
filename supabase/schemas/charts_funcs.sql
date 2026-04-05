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
                 and t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
                 and (t.transacted_at + t.local_offset) >= date_trunc('month', now())
                 and (t.transacted_at + t.local_offset) < date_trunc('month', now()) + interval '1 month'
                then t.charged_amount
            end
        ), 0) as monthly_income,

        -- EXPENSE (current month)
        coalesce(sum(
            case
                when t.charged_amount < 0
                 and t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
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
                 and t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
                 and (t.transacted_at + t.local_offset) >= date_trunc('month', now()) - interval '1 month'
                 and (t.transacted_at + t.local_offset) < date_trunc('month', now())
                then t.charged_amount
            end
        ), 0) as previous_monthly_income,

        -- EXPENSE (previous month)
        coalesce(sum(
            case
                when t.charged_amount < 0
                 and t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
                 and (t.transacted_at + t.local_offset) >= date_trunc('month', now()) - interval '1 month'
                 and (t.transacted_at + t.local_offset) < date_trunc('month', now())
                then t.charged_amount
            end
        ), 0) as previous_monthly_expense

    from public.transactions t
    where t.charged_currency_id = v_currency_id;
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

CREATE OR REPLACE FUNCTION public.get_daily_financial_overview_for_month(
  p_month         DATE,
  p_currency_code TEXT,
  p_account_ids   BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
  day              DATE,
  daily_income     NUMERIC,
  daily_expense    NUMERIC,
  running_balance  NUMERIC
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
WITH
  currency AS (
    SELECT id FROM public.currencies WHERE code = p_currency_code
  ),
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS ts
  ),
  month_end AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) + INTERVAL '1 month' AS ts
  ),
  days AS (
    SELECT gs::date AS day
    FROM generate_series(
      (SELECT ts FROM month_start)::date,
      ((SELECT ts FROM month_end) - INTERVAL '1 day')::date,
      INTERVAL '1 day'
    ) AS gs
  ),
  balance_before AS (
    SELECT COALESCE(SUM(t.charged_amount), 0) AS balance
    FROM public.transactions t
    JOIN currency c ON c.id = t.charged_currency_id
    WHERE (t.transacted_at + t.local_offset) < (SELECT ts FROM month_start)
      AND (
        p_account_ids IS NULL
        OR cardinality(p_account_ids) = 0
        OR t.account_id = ANY(p_account_ids)
      )
  ),
  daily_agg AS (
    SELECT
      (t.transacted_at + t.local_offset)::date AS day,
      COALESCE(SUM(t.charged_amount)
        FILTER (WHERE t.charged_amount > 0
          AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)), 0) AS daily_income,
      COALESCE(ABS(SUM(t.charged_amount)
        FILTER (WHERE t.charged_amount < 0
          AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type))), 0) AS daily_expense,
      COALESCE(SUM(t.charged_amount), 0) AS daily_net
    FROM public.transactions t
    JOIN currency c ON c.id = t.charged_currency_id
    WHERE (t.transacted_at + t.local_offset) >= (SELECT ts FROM month_start)
      AND (t.transacted_at + t.local_offset) <  (SELECT ts FROM month_end)
      AND (
        p_account_ids IS NULL
        OR cardinality(p_account_ids) = 0
        OR t.account_id = ANY(p_account_ids)
      )
    GROUP BY (t.transacted_at + t.local_offset)::date
  ),
  joined AS (
    SELECT
      d.day,
      COALESCE(a.daily_income,  0) AS daily_income,
      COALESCE(a.daily_expense, 0) AS daily_expense,
      COALESCE(a.daily_net,     0) AS daily_net
    FROM days d
    LEFT JOIN daily_agg a ON a.day = d.day
  )
SELECT
  j.day,
  j.daily_income,
  j.daily_expense,
  (SELECT balance FROM balance_before)
    + SUM(j.daily_net) OVER (ORDER BY j.day ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    AS running_balance
FROM joined j
ORDER BY j.day;
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

-- Returns total income and expense amounts per non-system group for a given month,
-- currency, and optional account filter. Used by the Statistics card donut chart.
CREATE OR REPLACE FUNCTION public.get_analytics_amounts_by_groups(
  p_month         DATE,
  p_currency_code TEXT,
  p_account_ids   BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
  group_id       BIGINT,
  group_name     TEXT,
  income_amount  NUMERIC,
  expense_amount NUMERIC
)
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  )
SELECT
  g.id                                                                            AS group_id,
  g.name                                                                          AS group_name,
  COALESCE(SUM(t.charged_amount)
    FILTER (WHERE t.charged_amount > 0
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)), 0)        AS income_amount,
  COALESCE(ABS(SUM(t.charged_amount)
    FILTER (WHERE t.charged_amount < 0
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type))), 0)       AS expense_amount
FROM public.transactions t
JOIN public.categories   cat ON cat.id = t.category_id
JOIN public.groups       g   ON g.id   = cat.group_id
JOIN public.currencies   cur ON cur.id = t.charged_currency_id
CROSS JOIN month_start   ms
WHERE cur.code    = p_currency_code
  AND g.is_system = false
  AND (t.transacted_at + t.local_offset) >= ms.val
  AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  AND (
    p_account_ids IS NULL
    OR cardinality(p_account_ids) = 0
    OR t.account_id = ANY(p_account_ids)
  )
GROUP BY g.id, g.name
ORDER BY expense_amount DESC, g.name;
$$;

CREATE OR REPLACE FUNCTION public.get_analytics_financial_summary(
  p_month         DATE,
  p_currency_code TEXT,
  p_account_ids   BIGINT[] DEFAULT NULL
)
RETURNS TABLE (
  monthly_income            NUMERIC,
  previous_monthly_income   NUMERIC,
  monthly_expense           NUMERIC,
  previous_monthly_expense  NUMERIC,
  total_balance             NUMERIC,
  previous_total_balance    NUMERIC,
  income_transaction_count  BIGINT,
  expense_transaction_count BIGINT,
  income_groups_count       BIGINT,
  expense_groups_count      BIGINT
)
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_currency_id BIGINT;
  v_month_start TIMESTAMP;
  v_month_end   TIMESTAMP;
  v_prev_start  TIMESTAMP;
  v_prev_end    TIMESTAMP;
BEGIN
  SELECT id INTO v_currency_id FROM public.currencies WHERE code = p_currency_code;

  v_month_start := date_trunc('month', p_month::TIMESTAMP);
  v_month_end   := v_month_start + INTERVAL '1 month';
  v_prev_start  := v_month_start - INTERVAL '1 month';
  v_prev_end    := v_month_start;

  RETURN QUERY
  SELECT
    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount > 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount > 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_prev_start
        AND (t.transacted_at + t.local_offset) <  v_prev_end), 0),

    COALESCE(ABS(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount < 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end)), 0),

    COALESCE(ABS(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount < 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_prev_start
        AND (t.transacted_at + t.local_offset) <  v_prev_end)), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE (t.transacted_at + t.local_offset) < v_month_end), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE (t.transacted_at + t.local_offset) < v_prev_end), 0),

    COUNT(*)
      FILTER (WHERE t.charged_amount > 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(*)
      FILTER (WHERE t.charged_amount < 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(DISTINCT cat.group_id)
      FILTER (WHERE t.charged_amount > 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(DISTINCT cat.group_id)
      FILTER (WHERE t.charged_amount < 0
        AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end)

  FROM public.transactions t
  JOIN public.categories cat ON cat.id = t.category_id
  WHERE t.charged_currency_id = v_currency_id
    AND (
      p_account_ids IS NULL
      OR cardinality(p_account_ids) = 0
      OR t.account_id = ANY(p_account_ids)
    );
END;
$$;
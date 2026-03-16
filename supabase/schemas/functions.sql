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

CREATE OR REPLACE FUNCTION get_recent_transactions (
  p_limit INTEGER DEFAULT 10
) returns TABLE (
  id BIGINT,
  transacted_at transactions.transacted_at % type,
  local_offset transactions.local_offset % type,
  transaction_amount transactions.transaction_amount % type,
  transaction_currency_code TEXT,
  account_id BIGINT,
  account_name TEXT,
  charged_amount transactions.charged_amount % type,
  charged_currency_code TEXT,
  exchange_rate NUMERIC,
  type transactions.type % type,
  group_id BIGINT,
  group_name TEXT,
  category_id BIGINT,
  category_name TEXT,
  comment transactions.comment % type
) language sql
SET
  search_path = '' AS $$
  select
    t.id,
    t.transacted_at,
    t.local_offset,
    t.transaction_amount,
    tc.code as transaction_currency_code,
    acc.id as account_id,
    acc.name as account_name,
    t.charged_amount,
    ac.code as charged_currency_code,
    (t.charged_amount / nullif(t.transaction_amount, 0)) as exchange_rate,
    t.type,
    cg.id as group_id,
    cg.name as group_name,
    cat.id as category_id,
    cat.name as category_name,
    t.comment
  from public.transactions t
  join public.accounts acc
    on acc.id = t.account_id
  join public.currencies ac
    on ac.id = t.charged_currency_id
  join public.currencies tc
    on tc.id = t.transaction_currency_id
  join public.categories cat
    on cat.id = t.category_id
  join public.groups cg
    on cg.id = cat.group_id
  where t.type <> 'transfer' and t.type <> 'internal'
  order by (t.transacted_at + t.local_offset) desc, t.id desc
  limit greatest(coalesce(p_limit, 10), 1);
$$;

CREATE OR REPLACE FUNCTION get_filtered_transactions (
  p_category_ids BIGINT[] DEFAULT NULL,
  p_account_ids BIGINT[] DEFAULT NULL,
  p_charged_currency_codes TEXT[] DEFAULT NULL,
  p_transaction_currency_codes TEXT[] DEFAULT NULL,
  p_transaction_type transactions.type % type DEFAULT NULL,
  p_month DATE DEFAULT NULL,
  p_page INTEGER DEFAULT 1,
  p_page_size INTEGER DEFAULT NULL
) returns TABLE (
  id BIGINT,
  transacted_at transactions.transacted_at % type,
  local_offset transactions.local_offset % type,
  transaction_amount transactions.transaction_amount % type,
  transaction_currency_code TEXT,
  account_id BIGINT,
  account_name TEXT,
  charged_amount transactions.charged_amount % type,
  charged_currency_code TEXT,
  exchange_rate NUMERIC,
  type transactions.type % type,
  group_id BIGINT,
  group_name TEXT,
  category_id BIGINT,
  category_name TEXT,
  comment transactions.comment % type
) language sql
SET
  search_path = '' AS $$
  select
    t.id,
    t.transacted_at,
    t.local_offset,
    t.transaction_amount,
    tc.code as transaction_currency_code,
    acc.id as account_id,
    acc.name as account_name,
    t.charged_amount,
    ac.code as charged_currency_code,
    (t.charged_amount / nullif(t.transaction_amount, 0)) as exchange_rate,
    t.type,
    cg.id as group_id,
    cg.name as group_name,
    cat.id as category_id,
    cat.name as category_name,
    t.comment
  from public.transactions t
  join public.accounts acc
    on acc.id = t.account_id
  join public.currencies ac
    on ac.id = t.charged_currency_id
  join public.currencies tc
    on tc.id = t.transaction_currency_id
  join public.categories cat
    on cat.id = t.category_id
  join public.groups cg
    on cg.id = cat.group_id
  where t.type <> 'internal'
    and (
      p_transaction_type is null
      or t.type = p_transaction_type
    )
    and (
      p_category_ids is null
      or cardinality(p_category_ids) = 0
      or t.category_id = any(p_category_ids)
    )
    and (
      p_account_ids is null
      or cardinality(p_account_ids) = 0
      or t.account_id = any(p_account_ids)
    )
    and (
      p_charged_currency_codes is null
      or cardinality(p_charged_currency_codes) = 0
      or ac.code = any(p_charged_currency_codes)
    )
    and (
      p_transaction_currency_codes is null
      or cardinality(p_transaction_currency_codes) = 0
      or tc.code = any(p_transaction_currency_codes)
    )
    and (
      p_month is null
      or (
        (t.transacted_at + t.local_offset) >= date_trunc('month', p_month::timestamp)
        and (t.transacted_at + t.local_offset) < date_trunc('month', p_month::timestamp) + interval '1 month'
      )
    )
  order by (t.transacted_at + t.local_offset) desc, t.id desc
  limit case when p_page_size is null then null else greatest(p_page_size, 1) end
  offset case when p_page_size is null then 0 else (greatest(coalesce(p_page, 1), 1) - 1) * greatest(p_page_size, 1) end;
$$;

CREATE OR REPLACE FUNCTION make_transfer (
  p_from_account_id BIGINT,
  p_to_account_id BIGINT,
  p_from_amount NUMERIC,
  p_to_amount NUMERIC DEFAULT NULL,
  p_comment TEXT DEFAULT NULL
) RETURNS void
SET
  search_path = '' AS $$
DECLARE
  tid uuid := gen_random_uuid();
  from_currency_id BIGINT;
  to_currency_id BIGINT;
  actual_to_amount NUMERIC;
  internal_category_id BIGINT;
BEGIN
  IF p_from_amount IS NULL OR p_from_amount <= 0 THEN
    RAISE EXCEPTION 'Transfer amount must be greater than 0';
  END IF;

  IF p_from_account_id IS NULL OR p_to_account_id IS NULL THEN
    RAISE EXCEPTION 'Both source and destination accounts are required';
  END IF;

  IF p_from_account_id = p_to_account_id THEN
    RAISE EXCEPTION 'Source and destination accounts must be different';
  END IF;

  SELECT a.currency_id
  INTO from_currency_id
  FROM public.accounts a
  WHERE a.id = p_from_account_id;

  IF from_currency_id IS NULL THEN
    RAISE EXCEPTION 'Source account % does not exist', p_from_account_id;
  END IF;

  SELECT a.currency_id
  INTO to_currency_id
  FROM public.accounts a
  WHERE a.id = p_to_account_id;

  IF to_currency_id IS NULL THEN
    RAISE EXCEPTION 'Destination account % does not exist', p_to_account_id;
  END IF;

  SELECT c.id
  INTO internal_category_id
  FROM public.categories c
  WHERE c.name = 'internal';

  IF internal_category_id IS NULL THEN
    RAISE EXCEPTION 'Internal category not found';
  END IF;

  -- For single-currency transfers, to_amount defaults to from_amount
  actual_to_amount := COALESCE(p_to_amount, p_from_amount);

  IF actual_to_amount <= 0 THEN
    RAISE EXCEPTION 'Destination amount must be greater than 0';
  END IF;

  INSERT INTO public.transactions (account_id, transaction_amount, charged_amount, type, category_id, transfer_id, comment, transaction_currency_id)
  VALUES (p_from_account_id, -p_from_amount, -p_from_amount, 'transfer', internal_category_id, tid, p_comment, from_currency_id);

  INSERT INTO public.transactions (account_id, transaction_amount, charged_amount, type, category_id, transfer_id, comment, transaction_currency_id)
  VALUES (p_to_account_id, actual_to_amount, actual_to_amount, 'transfer', internal_category_id, tid, p_comment, to_currency_id);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION public.get_regular_account_with_balance (
  p_account_id BIGINT
) RETURNS TABLE (
  id BIGINT,
  name TEXT,
  currency_code TEXT,
  currency_id BIGINT,
  balance NUMERIC,
  can_delete BOOLEAN
) LANGUAGE sql
SET
  search_path = '' AS $$
  SELECT
    r.id,
    r.name,
    r.currency_code,
    r.currency_id,
    r.balance,
    r.can_delete
  FROM public.regular_accounts_with_balance r
  WHERE r.id = p_account_id
  LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.adjust_account_balance (
  p_account_id BIGINT,
  p_target_balance NUMERIC,
  p_local_offset INTERVAL,
  p_comment TEXT DEFAULT NULL
) RETURNS BIGINT
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = ''
AS $$
DECLARE
  v_current_balance NUMERIC;
  v_adjustment_amount NUMERIC;
  v_internal_category_id BIGINT;
  v_account_currency_id BIGINT;
  v_inserted_transaction_id BIGINT;
BEGIN
  IF p_account_id IS NULL THEN
    RAISE EXCEPTION 'Account id is required';
  END IF;

  IF p_target_balance IS NULL THEN
    RAISE EXCEPTION 'Target balance is required';
  END IF;

  IF p_local_offset IS NULL THEN
    RAISE EXCEPTION 'Local offset is required';
  END IF;

  SELECT r.balance
  INTO v_current_balance
  FROM public.regular_accounts_with_balance r
  WHERE r.id = p_account_id;

  IF v_current_balance IS NULL THEN
    RAISE EXCEPTION 'Regular account % does not exist', p_account_id;
  END IF;

  SELECT a.currency_id
  INTO v_account_currency_id
  FROM public.accounts a
  WHERE a.id = p_account_id
    AND a.type = 'regular';

  IF v_account_currency_id IS NULL THEN
    RAISE EXCEPTION 'Regular account % does not exist', p_account_id;
  END IF;

  v_adjustment_amount := p_target_balance - v_current_balance;

  IF v_adjustment_amount = 0 THEN
    RETURN NULL;
  END IF;

  SELECT c.id
  INTO v_internal_category_id
  FROM public.categories c
  JOIN public.groups g
    ON g.id = c.group_id
  WHERE c.name = 'internal'
    AND g.name = 'internal'
    AND c.is_system = true
    AND g.is_system = true
  LIMIT 1;

  IF v_internal_category_id IS NULL THEN
    RAISE EXCEPTION 'Internal category not found';
  END IF;

  INSERT INTO public.transactions (
    account_id,
    local_offset,
    transaction_amount,
    charged_amount,
    type,
    category_id,
    transaction_currency_id,
    comment
  )
  VALUES (
    p_account_id,
    p_local_offset,
    v_adjustment_amount,
    v_adjustment_amount,
    'internal',
    v_internal_category_id,
    v_account_currency_id,
    p_comment
  )
  RETURNING id INTO v_inserted_transaction_id;

  RETURN v_inserted_transaction_id;
END;
$$;
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
        coalesce(sum(t.account_amount), 0) as total_balance,

        -- INCOME (current month)
        coalesce(sum(
            case
                when t.account_amount > 0
                 and t.transacted_at >= date_trunc('month', now())
                 and t.transacted_at < date_trunc('month', now()) + interval '1 month'
                then t.account_amount
            end
        ), 0) as monthly_income,

        -- EXPENSE (current month)
        coalesce(sum(
            case
                when t.account_amount < 0
                 and t.transacted_at >= date_trunc('month', now())
                 and t.transacted_at < date_trunc('month', now()) + interval '1 month'
                then t.account_amount
            end
        ), 0) as monthly_expense,


        -- BALANCE (up to previous month end)
        coalesce(sum(
            case
                when t.transacted_at < date_trunc('month', now())
                then t.account_amount
            end
        ), 0) as previous_total_balance,

        -- INCOME (previous month)
        coalesce(sum(
            case
                when t.account_amount > 0
                 and t.transacted_at >= date_trunc('month', now()) - interval '1 month'
                 and t.transacted_at < date_trunc('month', now())
                then t.account_amount
            end
        ), 0) as previous_monthly_income,

        -- EXPENSE (previous month)
        coalesce(sum(
            case
                when t.account_amount < 0
                 and t.transacted_at >= date_trunc('month', now()) - interval '1 month'
                 and t.transacted_at < date_trunc('month', now())
                then t.account_amount
            end
        ), 0) as previous_monthly_expense

    from public.transactions t
    where t.account_currency_id = v_currency_id;
end;
$$;

CREATE OR REPLACE FUNCTION get_monthly_cash_flow (p_currency_code TEXT, p_months INTEGER DEFAULT 6) returns TABLE (
  MONTH TIMESTAMP WITH TIME ZONE,
  total_income NUMERIC,
  total_expense NUMERIC
) language sql
SET
  search_path = '' AS $$
  select
    date_trunc('month', t.transacted_at) as month,
    sum(case when t.account_amount > 0 then t.account_amount else 0 end) as total_income,
    sum(case when t.account_amount < 0 then t.account_amount else 0 end) as total_expense
  from public.transactions t
  join public.currencies c
    on c.id = t.account_currency_id
  where c.code = p_currency_code
    and t.transacted_at >= date_trunc('month', now()) 
        - make_interval(months => p_months - 1)
  group by date_trunc('month', t.transacted_at)
  order by month;
$$;

CREATE OR REPLACE FUNCTION get_recent_transactions (
  p_account_currency_code TEXT,
   p_size INTEGER DEFAULT 10
) returns TABLE (
  id BIGINT,
  transacted_at transactions.transacted_at % type,
  transaction_amount transactions.transaction_amount % type,
  transaction_currency_code TEXT,
  account_name TEXT,
  account_amount transactions.account_amount % type,
  account_currency_code TEXT,
  exchange_rate NUMERIC,
  type transactions.type % type,
  category_name TEXT,
  group_name TEXT,
  comment transactions.comment % type
) language sql
SET
  search_path = '' AS $$
  select
    t.id,
    t.transacted_at,
    t.transaction_amount,
    tc.code as transaction_currency_code,
    acc.name as account_name,
    t.account_amount,
    ac.code as account_currency_code,
    (t.account_amount / nullif(t.transaction_amount, 0)) as exchange_rate,
    t.type,
    cat.name as category_name,
    cg.name as group_name,
    t.comment
  from public.transactions t
  join public.accounts acc
    on acc.id = t.account_id
  join public.currencies ac
    on ac.id = t.account_currency_id
  join public.currencies tc
    on tc.id = t.transaction_currency_id
  join public.categories cat
    on cat.id = t.category_id
  join public.groups cg
    on cg.id = cat.group_id
  where ac.code = p_account_currency_code
  order by t.transacted_at desc, t.id desc
  limit greatest(coalesce(p_size, 10), 1);
$$;

CREATE OR REPLACE FUNCTION get_filtered_transactions (
  p_category_ids BIGINT[] DEFAULT NULL,
  p_account_ids BIGINT[] DEFAULT NULL,
  p_account_currency_codes TEXT[] DEFAULT NULL,
  p_transaction_currency_codes TEXT[] DEFAULT NULL,
  p_month DATE DEFAULT NULL,
  p_page INTEGER DEFAULT 1,
  p_page_size INTEGER DEFAULT 10
) returns TABLE (
  id BIGINT,
  transacted_at transactions.transacted_at % type,
  transaction_amount transactions.transaction_amount % type,
  transaction_currency_code TEXT,
  account_name TEXT,
  account_amount transactions.account_amount % type,
  account_currency_code TEXT,
  exchange_rate NUMERIC,
  type transactions.type % type,
  category_name TEXT,
  group_name TEXT,
  comment transactions.comment % type
) language sql
SET
  search_path = '' AS $$
  select
    t.id,
    t.transacted_at,
    t.transaction_amount,
    tc.code as transaction_currency_code,
    acc.name as account_name,
    t.account_amount,
    ac.code as account_currency_code,
    (t.account_amount / nullif(t.transaction_amount, 0)) as exchange_rate,
    t.type,
    cat.name as category_name,
    cg.name as group_name,
    t.comment
  from public.transactions t
  join public.accounts acc
    on acc.id = t.account_id
  join public.currencies ac
    on ac.id = t.account_currency_id
  join public.currencies tc
    on tc.id = t.transaction_currency_id
  join public.categories cat
    on cat.id = t.category_id
  join public.groups cg
    on cg.id = cat.group_id
  where (
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
      p_account_currency_codes is null
      or cardinality(p_account_currency_codes) = 0
      or ac.code = any(p_account_currency_codes)
    )
    and (
      p_transaction_currency_codes is null
      or cardinality(p_transaction_currency_codes) = 0
      or tc.code = any(p_transaction_currency_codes)
    )
    and (
      p_month is null
      or (
        t.transacted_at >= date_trunc('month', p_month::timestamp)
        and t.transacted_at < date_trunc('month', p_month::timestamp) + interval '1 month'
      )
    )
  order by t.transacted_at desc, t.id desc
  limit greatest(coalesce(p_page_size, 10), 1)
  offset (greatest(coalesce(p_page, 1), 1) - 1) * greatest(coalesce(p_page_size, 10), 1);
$$;

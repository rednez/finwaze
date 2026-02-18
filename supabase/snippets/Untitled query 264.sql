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
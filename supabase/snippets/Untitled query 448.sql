CREATE OR REPLACE FUNCTION get_transfer_transactions (
  p_transaction_id BIGINT
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
  comment transactions.comment % type,
  transfer_id transactions.transfer_id % type
) language sql
SET
  search_path = '' AS $$
  with transfer_ref as (
    select transfer_id
    from public.transactions
    where id = p_transaction_id
      and type = 'transfer'
  )
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
    t.comment,
    t.transfer_id
  from public.transactions t
  join transfer_ref tr
    on t.transfer_id = tr.transfer_id
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
  where t.type = 'transfer';
$$;
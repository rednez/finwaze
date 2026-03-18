drop function if exists "public"."get_filtered_transactions"(p_category_ids bigint[], p_account_ids bigint[], p_charged_currency_codes text[], p_transaction_currency_codes text[], p_transaction_type public.transaction_type, p_month date, p_page integer, p_page_size integer);

drop function if exists "public"."get_recent_transactions"(p_limit integer);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_transfer_transactions(p_transaction_id bigint)
 RETURNS TABLE(id bigint, transacted_at timestamp with time zone, local_offset interval, transaction_amount numeric, transaction_currency_code text, account_id bigint, account_name text, charged_amount numeric, charged_currency_code text, exchange_rate numeric, type public.transaction_type, group_id bigint, group_name text, category_id bigint, category_name text, comment text, transfer_id uuid)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_filtered_transactions(p_category_ids bigint[] DEFAULT NULL::bigint[], p_account_ids bigint[] DEFAULT NULL::bigint[], p_charged_currency_codes text[] DEFAULT NULL::text[], p_transaction_currency_codes text[] DEFAULT NULL::text[], p_transaction_type public.transaction_type DEFAULT NULL::public.transaction_type, p_month date DEFAULT NULL::date, p_page integer DEFAULT 1, p_page_size integer DEFAULT NULL::integer)
 RETURNS TABLE(id bigint, transacted_at timestamp with time zone, local_offset interval, transaction_amount numeric, transaction_currency_code text, account_id bigint, account_name text, charged_amount numeric, charged_currency_code text, exchange_rate numeric, type public.transaction_type, group_id bigint, group_name text, category_id bigint, category_name text, comment text, transfer_id uuid)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_recent_transactions(p_limit integer DEFAULT 10)
 RETURNS TABLE(id bigint, transacted_at timestamp with time zone, local_offset interval, transaction_amount numeric, transaction_currency_code text, account_id bigint, account_name text, charged_amount numeric, charged_currency_code text, exchange_rate numeric, type public.transaction_type, group_id bigint, group_name text, category_id bigint, category_name text, comment text, transfer_id uuid)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
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
  order by (t.transacted_at + t.local_offset) desc, t.id desc
  limit greatest(coalesce(p_limit, 10), 1);
$function$
;



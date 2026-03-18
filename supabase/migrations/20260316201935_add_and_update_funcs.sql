set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.adjust_account_balance(p_account_id bigint, p_target_balance numeric, p_local_offset interval, p_comment text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_regular_account_with_balance(p_account_id bigint)
 RETURNS TABLE(id bigint, name text, currency_code text, currency_id bigint, balance numeric, can_delete boolean)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
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
$function$
;

create or replace view "public"."regular_accounts_with_balance" WITH
  (security_invoker = TRUE) as  SELECT a.id,
    a.name,
    c.code AS currency_code,
    c.id AS currency_id,
    COALESCE(sum(t.charged_amount), (0)::numeric) AS balance,
    (NOT (EXISTS ( SELECT 1
           FROM public.transactions t_1
          WHERE ((t_1.account_id = a.id) AND (t_1.type <> 'internal'::public.transaction_type))))) AS can_delete
   FROM ((public.accounts a
     JOIN public.currencies c ON ((c.id = a.currency_id)))
     LEFT JOIN public.transactions t ON ((t.account_id = a.id)))
  WHERE (a.type = 'regular'::public.account_type)
  GROUP BY a.id, a.name, c.code, c.id
  ORDER BY a.name;


CREATE OR REPLACE FUNCTION public.get_dashboard_totals(p_currency_code text)
 RETURNS TABLE(total_balance numeric, monthly_income numeric, monthly_expense numeric, previous_total_balance numeric, previous_monthly_income numeric, previous_monthly_expense numeric)
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_filtered_transactions(p_category_ids bigint[] DEFAULT NULL::bigint[], p_account_ids bigint[] DEFAULT NULL::bigint[], p_charged_currency_codes text[] DEFAULT NULL::text[], p_transaction_currency_codes text[] DEFAULT NULL::text[], p_transaction_type public.transaction_type DEFAULT NULL::public.transaction_type, p_month date DEFAULT NULL::date, p_page integer DEFAULT 1, p_page_size integer DEFAULT NULL::integer)
 RETURNS TABLE(id bigint, transacted_at timestamp with time zone, local_offset interval, transaction_amount numeric, transaction_currency_code text, account_id bigint, account_name text, charged_amount numeric, charged_currency_code text, exchange_rate numeric, type public.transaction_type, group_id bigint, group_name text, category_id bigint, category_name text, comment text)
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_monthly_charged_cash_flow(p_currency_code text, p_months integer DEFAULT 6)
 RETURNS TABLE(month timestamp with time zone, total_income numeric, total_expense numeric)
 LANGUAGE sql
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_recent_transactions(p_limit integer DEFAULT 10)
 RETURNS TABLE(id bigint, transacted_at timestamp with time zone, local_offset interval, transaction_amount numeric, transaction_currency_code text, account_id bigint, account_name text, charged_amount numeric, charged_currency_code text, exchange_rate numeric, type public.transaction_type, group_id bigint, group_name text, category_id bigint, category_name text, comment text)
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
$function$
;



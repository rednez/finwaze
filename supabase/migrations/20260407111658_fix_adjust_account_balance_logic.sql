drop function if exists "public"."adjust_account_balance"(p_account_id bigint, p_target_balance numeric, p_local_offset interval, p_comment text, p_transacted_at timestamp with time zone);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.adjust_account_balance(p_account_id bigint, p_target_balance numeric, p_local_offset interval, p_comment text DEFAULT NULL::text, p_balance_date timestamp with time zone DEFAULT now())
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

  SELECT a.currency_id
  INTO v_account_currency_id
  FROM public.accounts a
  WHERE a.id = p_account_id
    AND a.type = 'regular';

  IF v_account_currency_id IS NULL THEN
    RAISE EXCEPTION 'Regular account % does not exist', p_account_id;
  END IF;

  SELECT COALESCE(SUM(t.charged_amount), 0)
  INTO v_current_balance
  FROM public.transactions t
  WHERE t.account_id = p_account_id
    AND (t.transacted_at + t.local_offset)::date <= (p_balance_date + p_local_offset)::date;

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
    comment,
    transacted_at
  )
  VALUES (
    p_account_id,
    p_local_offset,
    v_adjustment_amount,
    v_adjustment_amount,
    'internal',
    v_internal_category_id,
    v_account_currency_id,
    p_comment,
    p_balance_date
  )
  RETURNING id INTO v_inserted_transaction_id;

  RETURN v_inserted_transaction_id;
END;
$function$
;



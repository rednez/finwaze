CREATE OR REPLACE FUNCTION public.get_regular_account_with_balance (p_account_id BIGINT) RETURNS TABLE (
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
) RETURNS BIGINT LANGUAGE plpgsql SECURITY INVOKER
SET
  search_path = '' AS $$
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
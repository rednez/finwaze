CREATE OR REPLACE FUNCTION make_transfer (
  p_from_account BIGINT,
  p_to_account BIGINT,
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

  IF p_from_account IS NULL OR p_to_account IS NULL THEN
    RAISE EXCEPTION 'Both source and destination accounts are required';
  END IF;

  IF p_from_account = p_to_account THEN
    RAISE EXCEPTION 'Source and destination accounts must be different';
  END IF;

  SELECT a.currency_id
  INTO from_currency_id
  FROM public.accounts a
  WHERE a.id = p_from_account;

  IF from_currency_id IS NULL THEN
    RAISE EXCEPTION 'Source account % does not exist', p_from_account;
  END IF;

  SELECT a.currency_id
  INTO to_currency_id
  FROM public.accounts a
  WHERE a.id = p_to_account;

  IF to_currency_id IS NULL THEN
    RAISE EXCEPTION 'Destination account % does not exist', p_to_account;
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

  INSERT INTO public.transactions (account_id, transaction_amount, account_amount, type, category_id, transfer_id, comment, transaction_currency_id)
  VALUES (p_from_account, -p_from_amount, -p_from_amount, 'transfer', internal_category_id, tid, p_comment, from_currency_id);

  INSERT INTO public.transactions (account_id, transaction_amount, account_amount, type, category_id, transfer_id, comment, transaction_currency_id)
  VALUES (p_to_account, actual_to_amount, actual_to_amount, 'transfer', internal_category_id, tid, p_comment, to_currency_id);
END;
$$ LANGUAGE plpgsql;
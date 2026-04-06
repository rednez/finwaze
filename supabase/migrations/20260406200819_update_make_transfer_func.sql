drop function if exists "public"."make_transfer"(p_from_account_id bigint, p_to_account_id bigint, p_from_amount numeric, p_to_amount numeric, p_local_offset interval, p_comment text);

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.make_transfer(p_from_account_id bigint, p_to_account_id bigint, p_from_amount numeric, p_to_amount numeric DEFAULT NULL::numeric, p_local_offset interval DEFAULT '00:00:00'::interval, p_comment text DEFAULT NULL::text, p_transacted_at timestamp with time zone DEFAULT now())
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
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

  IF from_currency_id = to_currency_id AND actual_to_amount <> p_from_amount THEN
    RAISE EXCEPTION 'Amounts must be equal when both accounts use the same currency';
  END IF;

  IF actual_to_amount <= 0 THEN
    RAISE EXCEPTION 'Destination amount must be greater than 0';
  END IF;

  INSERT INTO public.transactions (account_id, transaction_amount, charged_amount, type, category_id, transfer_id, comment, transaction_currency_id, local_offset, transacted_at)
  VALUES (p_from_account_id, -p_from_amount, -p_from_amount, 'transfer', internal_category_id, tid, p_comment, from_currency_id, p_local_offset, p_transacted_at);

  INSERT INTO public.transactions (account_id, transaction_amount, charged_amount, type, category_id, transfer_id, comment, transaction_currency_id, local_offset, transacted_at)
  VALUES (p_to_account_id, actual_to_amount, actual_to_amount, 'transfer', internal_category_id, tid, p_comment, to_currency_id, p_local_offset, p_transacted_at);
END;
$function$
;



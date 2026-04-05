set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.cancel_savings_goal(p_account_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
BEGIN
  UPDATE public.savings_goals
  SET is_cancelled = true
  WHERE account_id = p_account_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Savings goal for account % not found', p_account_id;
  END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_savings_goal(p_name text, p_currency_id bigint, p_target_amount numeric, p_target_date date)
 RETURNS bigint
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
  v_account_id bigint;
BEGIN
  INSERT INTO public.accounts (name, currency_id, type)
  VALUES (p_name, p_currency_id, 'savings_goal'::public.account_type)
  RETURNING id INTO v_account_id;

  INSERT INTO public.savings_goals (account_id, target_amount, target_date)
  VALUES (v_account_id, p_target_amount, p_target_date);

  RETURN v_account_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_savings_goal(p_account_id bigint)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
BEGIN
  DELETE FROM public.transactions
  WHERE account_id = p_account_id;

  DELETE FROM public.accounts
  WHERE id = p_account_id
    AND type = 'savings_goal'::public.account_type;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Savings goal account % not found', p_account_id;
  END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_savings_goal(p_account_id bigint, p_name text, p_target_amount numeric, p_target_date date)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
BEGIN
  UPDATE public.accounts
  SET name = p_name
  WHERE id = p_account_id
    AND type = 'savings_goal'::public.account_type;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Savings goal account % not found', p_account_id;
  END IF;

  UPDATE public.savings_goals
  SET target_amount = p_target_amount,
      target_date   = p_target_date
  WHERE account_id = p_account_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Savings goal record for account % not found', p_account_id;
  END IF;
END;
$function$
;



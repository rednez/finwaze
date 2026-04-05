alter table "public"."monthly_budgets" add constraint "monthly_budgets_planned_amount_positive" CHECK ((planned_amount > (0)::numeric)) not valid;

alter table "public"."monthly_budgets" validate constraint "monthly_budgets_planned_amount_positive";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.upsert_monthly_budgets(p_month date, p_currency_code text, p_categories jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
DECLARE
  v_currency_id bigint;
  v_month_start date;
BEGIN
  SELECT id INTO v_currency_id
  FROM public.currencies
  WHERE code = p_currency_code
  LIMIT 1;

  IF v_currency_id IS NULL THEN
    RAISE EXCEPTION 'Currency not found: %', p_currency_code;
  END IF;

  v_month_start := date_trunc('month', p_month::timestamp)::date;

  -- DELETE: remove rows not present in the new list (or with planned_amount = 0)
  DELETE FROM public.monthly_budgets
  WHERE budget_month = v_month_start
    AND currency_id  = v_currency_id
    AND category_id NOT IN (
      SELECT (item->>'category_id')::bigint
      FROM jsonb_array_elements(p_categories) AS item
      WHERE (item->>'planned_amount')::numeric > 0
    );

  -- INSERT new / UPDATE existing via ON CONFLICT
  INSERT INTO public.monthly_budgets (budget_month, category_id, currency_id, planned_amount)
  SELECT
    v_month_start,
    (item->>'category_id')::bigint,
    v_currency_id,
    (item->>'planned_amount')::numeric
  FROM jsonb_array_elements(p_categories) AS item
  WHERE (item->>'planned_amount')::numeric > 0
  ON CONFLICT (user_id, budget_month, category_id, currency_id)
  DO UPDATE SET
    planned_amount = EXCLUDED.planned_amount
  WHERE public.monthly_budgets.planned_amount IS DISTINCT FROM EXCLUDED.planned_amount;
  -- updated_at is updated automatically by the existing trigger
END;
$function$
;



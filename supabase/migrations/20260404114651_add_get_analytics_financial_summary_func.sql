set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_analytics_financial_summary(p_month date, p_currency_code text, p_account_ids bigint[] DEFAULT NULL::bigint[])
 RETURNS TABLE(monthly_income numeric, previous_monthly_income numeric, monthly_expense numeric, previous_monthly_expense numeric, total_balance numeric, previous_total_balance numeric, income_transaction_count bigint, expense_transaction_count bigint, income_groups_count bigint, expense_groups_count bigint)
 LANGUAGE plpgsql
 STABLE
 SET search_path TO ''
AS $function$
DECLARE
  v_currency_id BIGINT;
  v_month_start TIMESTAMP;
  v_month_end   TIMESTAMP;
  v_prev_start  TIMESTAMP;
  v_prev_end    TIMESTAMP;
BEGIN
  SELECT id INTO v_currency_id FROM public.currencies WHERE code = p_currency_code;

  v_month_start := date_trunc('month', p_month::TIMESTAMP);
  v_month_end   := v_month_start + INTERVAL '1 month';
  v_prev_start  := v_month_start - INTERVAL '1 month';
  v_prev_end    := v_month_start;

  RETURN QUERY
  SELECT
    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_prev_start
        AND (t.transacted_at + t.local_offset) <  v_prev_end), 0),

    COALESCE(ABS(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end)), 0),

    COALESCE(ABS(SUM(t.charged_amount)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_prev_start
        AND (t.transacted_at + t.local_offset) <  v_prev_end)), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE (t.transacted_at + t.local_offset) < v_month_end), 0),

    COALESCE(SUM(t.charged_amount)
      FILTER (WHERE (t.transacted_at + t.local_offset) < v_prev_end), 0),

    COUNT(*)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(*)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(DISTINCT cat.group_id)
      FILTER (WHERE t.charged_amount > 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end),

    COUNT(DISTINCT cat.group_id)
      FILTER (WHERE t.charged_amount < 0
        AND (t.transacted_at + t.local_offset) >= v_month_start
        AND (t.transacted_at + t.local_offset) <  v_month_end)

  FROM public.transactions t
  JOIN public.categories cat ON cat.id = t.category_id
  WHERE t.charged_currency_id = v_currency_id
    AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
    AND (
      p_account_ids IS NULL
      OR cardinality(p_account_ids) = 0
      OR t.account_id = ANY(p_account_ids)
    );
END;
$function$
;



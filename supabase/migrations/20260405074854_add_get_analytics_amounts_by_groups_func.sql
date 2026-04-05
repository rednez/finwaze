set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_analytics_amounts_by_groups(p_month date, p_currency_code text, p_account_ids bigint[] DEFAULT NULL::bigint[])
 RETURNS TABLE(group_id bigint, group_name text, income_amount numeric, expense_amount numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  )
SELECT
  g.id                                                                            AS group_id,
  g.name                                                                          AS group_name,
  COALESCE(SUM(t.charged_amount)
    FILTER (WHERE t.charged_amount > 0
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)), 0)        AS income_amount,
  COALESCE(ABS(SUM(t.charged_amount)
    FILTER (WHERE t.charged_amount < 0
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type))), 0)       AS expense_amount
FROM public.transactions t
JOIN public.categories   cat ON cat.id = t.category_id
JOIN public.groups       g   ON g.id   = cat.group_id
JOIN public.currencies   cur ON cur.id = t.charged_currency_id
CROSS JOIN month_start   ms
WHERE cur.code    = p_currency_code
  AND g.is_system = false
  AND (t.transacted_at + t.local_offset) >= ms.val
  AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  AND (
    p_account_ids IS NULL
    OR cardinality(p_account_ids) = 0
    OR t.account_id = ANY(p_account_ids)
  )
GROUP BY g.id, g.name
ORDER BY expense_amount DESC, g.name;
$function$
;



drop function if exists "public"."get_savings_goal_balances"(p_limit integer);

alter table "public"."savings_goals" drop column "amount";

alter table "public"."savings_goals" drop column "end_date";

alter table "public"."savings_goals" drop column "start_date";

alter table "public"."savings_goals" drop column "status";

alter table "public"."savings_goals" add column "is_cancelled" boolean not null default false;

alter table "public"."savings_goals" add column "target_amount" numeric not null;

alter table "public"."savings_goals" add column "target_date" date not null;

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.get_savings_goals(p_limit integer DEFAULT NULL::integer, p_status public.savings_goal_status DEFAULT NULL::public.savings_goal_status, p_period_to date DEFAULT NULL::date)
 RETURNS TABLE(id bigint, name text, currency_code text, target_date date, status public.savings_goal_status, target_amount numeric, accumulated_amount numeric)
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
  WITH goal_data AS (
    SELECT
      acc.id,
      acc.name,
      cur.code AS currency_code,
      sg.target_date,
      sg.target_amount,
      sg.is_cancelled,
      COALESCE(SUM(t.charged_amount), 0) AS accumulated_amount,
      acc.created_at
    FROM public.accounts acc
    JOIN public.currencies cur ON cur.id = acc.currency_id
    JOIN public.savings_goals sg ON sg.account_id = acc.id
    LEFT JOIN public.transactions t ON t.account_id = acc.id
    WHERE acc.type = 'savings_goal'::public.account_type
      AND (p_period_to IS NULL OR sg.target_date <= p_period_to)
    GROUP BY acc.id, acc.name, cur.code, sg.target_date, sg.target_amount, sg.is_cancelled, acc.created_at
  ),
  goal_with_status AS (
    SELECT
      id,
      name,
      currency_code,
      target_date,
      target_amount,
      accumulated_amount,
      created_at,
      CASE
        WHEN is_cancelled THEN 'cancelled'::public.savings_goal_status
        WHEN accumulated_amount >= target_amount THEN 'done'::public.savings_goal_status
        WHEN accumulated_amount > 0 THEN 'in_progress'::public.savings_goal_status
        ELSE 'not_started'::public.savings_goal_status
      END AS status
    FROM goal_data
  )
  SELECT id, name, currency_code, target_date, status, target_amount, accumulated_amount
  FROM goal_with_status
  WHERE (p_status IS NULL OR status = p_status)
  ORDER BY created_at DESC
  LIMIT p_limit;
$function$
;



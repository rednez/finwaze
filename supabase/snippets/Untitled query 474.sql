CREATE OR REPLACE FUNCTION get_recent_monthly_budgets (
  p_currency_code TEXT
) returns TABLE (
  category_name TEXT,
  total_budget NUMERIC
) language sql
SET
  search_path = '' AS $$
  select
    cat.name as category_name,
    sum(mb.planned_amount) as total_budget
  from public.monthly_budgets mb
  join public.categories cat
    on cat.id = mb.category_id
  join public.currencies cur
    on cur.id = mb.currency_id
  where cur.code = p_currency_code
    and mb.budget_month = date_trunc('month', now()::timestamp)::date
  group by cat.name
  order by total_budget desc, category_name asc;
$$;
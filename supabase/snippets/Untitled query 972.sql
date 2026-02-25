select
  coalesce(sum(mb.planned_amount), 0) as total_budget
from public.monthly_budgets mb
where mb.budget_month = date_trunc('month', now()::timestamp)::date;
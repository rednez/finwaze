SELECT public.upsert_monthly_budgets(
  '2026-03-01',
  'UAH',
  '[
    { "category_id": 2, "planned_amount": 0 }
  ]'::jsonb
);
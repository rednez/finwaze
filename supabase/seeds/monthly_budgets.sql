DO $$
DECLARE
  v_user_id UUID;
  v_month   DATE;
  v_months  DATE[] := ARRAY[
    '2025-01-01'::date, '2025-02-01'::date, '2025-03-01'::date,
    '2025-04-01'::date, '2025-05-01'::date, '2025-06-01'::date,
    '2025-07-01'::date, '2025-08-01'::date, '2025-09-01'::date,
    '2025-10-01'::date, '2025-11-01'::date, '2025-12-01'::date,
    '2026-01-01'::date, '2026-02-01'::date, '2026-03-01'::date
  ];
BEGIN
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'demo@mail.com';

  FOREACH v_month IN ARRAY v_months LOOP
    INSERT INTO public.monthly_budgets (user_id, budget_month, category_id, currency_id, planned_amount)
    SELECT
      v_user_id,
      v_month,
      c.id,
      cur.id,
      -- Base: stable amount for category+currency, step 150, range 500-5000
      (500 + (abs(hashtext(c.name || cur.code)) % 31) * 150)
      -- Monthly drift: deviation ±200, step 50, seeded by month
      + ((abs(hashtext(c.name || cur.code || v_month::text)) % 9) - 4) * 50
    FROM public.categories c
    JOIN public.groups     g   ON g.id  = c.group_id
    JOIN public.currencies cur ON cur.code IN ('UAH', 'USD', 'CZK', 'EUR')
    WHERE c.user_id   = v_user_id
      AND c.is_system = false;
  END LOOP;
END;
$$;
INSERT INTO public.accounts (
  user_id,
  name,
  currency_id,
  type
)
VALUES
  (
    (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
    'Goal: Emergency Fund',
    (SELECT id FROM public.currencies WHERE code = 'USD' LIMIT 1),
    'savings_goal'
  ),
  (
    (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
    'Goal: New Laptop',
    (SELECT id FROM public.currencies WHERE code = 'UAH' LIMIT 1),
    'savings_goal'
  ),
  (
    (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
    'Goal: Vacation',
    (SELECT id FROM public.currencies WHERE code = 'EUR' LIMIT 1),
    'savings_goal'
  );

INSERT INTO public.savings_goals (
  user_id,
  target_date,
  target_amount,
  account_id
)
VALUES
  (
    (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
    CURRENT_DATE + 90,
    1500.00,
    (SELECT id FROM public.accounts WHERE name = 'Goal: Emergency Fund' AND type = 'savings_goal' LIMIT 1)
  ),
  (
    (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
    CURRENT_DATE + 120,
    80000.00,
    (SELECT id FROM public.accounts WHERE name = 'Goal: New Laptop' AND type = 'savings_goal' LIMIT 1)
  ),
  (
    (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
    CURRENT_DATE + 60,
    2000.00,
    (SELECT id FROM public.accounts WHERE name = 'Goal: Vacation' AND type = 'savings_goal' LIMIT 1)
  );

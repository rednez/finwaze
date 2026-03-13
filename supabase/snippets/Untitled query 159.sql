SELECT EXISTS (
  SELECT 1
  FROM public.transactions
) AS has_transactions;
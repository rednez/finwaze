SELECT 
    SUM(t.transaction_amount) AS total_uah
FROM public.transactions t
JOIN public.currencies c 
    ON c.id = t.transaction_currency_id
WHERE c.code = 'UAH'
  AND t.transacted_at >= now() - interval '1 year';
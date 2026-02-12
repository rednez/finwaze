SELECT transaction_amount, c.code as currency, transacted_at
FROM public.transactions t
join currencies c on c.id = t.transaction_currency_id
WHERE t.transacted_at >= '2025-01-01'
  AND t.transacted_at <  '2025-01-02'
ORDER BY t.transacted_at;
SELECT
    date_trunc('month', t.transacted_at)::date AS month,
    SUM(CASE WHEN t.type = 'income'  THEN t.transaction_amount ELSE 0 END) AS total_income,
    SUM(CASE WHEN t.type = 'expense' THEN t.transaction_amount ELSE 0 END) AS total_expense,
    SUM(
        CASE 
            WHEN t.type = 'income'  THEN t.transaction_amount
            WHEN t.type = 'expense' THEN -t.transaction_amount
        END
    ) AS net_amount
FROM public.transactions t
JOIN public.currencies c 
    ON c.id = t.transaction_currency_id
WHERE t.transacted_at >= now() - interval '12 months'
  AND c.code = 'UAH'
GROUP BY date_trunc('month', t.transacted_at)
ORDER BY month;
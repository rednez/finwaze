CREATE OR REPLACE VIEW public.regular_accounts_with_balance
WITH
  (security_invoker = TRUE) AS
SELECT
  a.id,
  a.name,
  c.code AS currency_code,
  COALESCE(SUM(t.charged_amount), 0) AS balance
FROM
  accounts a
  JOIN currencies c ON c.id = a.currency_id
  LEFT JOIN transactions t ON t.account_id = a.id
WHERE
  a.type = 'regular'
GROUP BY
  a.id,
  a.name,
  c.code
ORDER BY
  a.name;
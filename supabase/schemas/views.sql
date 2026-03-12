CREATE OR REPLACE VIEW public.groups_with_categories_tx_counts
WITH (security_invoker = true) AS
WITH category_tx_counts AS (
  SELECT
    c.id,
    c.group_id,
    c.name,
    COUNT(t.id)::int AS transactions_count
  FROM public.categories c
  LEFT JOIN public.transactions t
    ON t.category_id = c.id
  WHERE c.is_system = false
  GROUP BY c.id, c.group_id, c.name
)
SELECT
  g.id,
  g.name,
  g.transaction_type,
  COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', ctc.id,
        'name', ctc.name,
        'transactions_count', ctc.transactions_count
      )
      ORDER BY ctc.id
    ) FILTER (WHERE ctc.id IS NOT NULL),
    '[]'::jsonb
  ) AS categories
FROM public.groups g
LEFT JOIN category_tx_counts ctc
  ON ctc.group_id = g.id
WHERE g.is_system = false
GROUP BY g.id, g.name, g.transaction_type;

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
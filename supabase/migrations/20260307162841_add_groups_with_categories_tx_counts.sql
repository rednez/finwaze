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
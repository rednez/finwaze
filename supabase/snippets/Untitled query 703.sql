SELECT *
FROM public.transactions t
WHERE t.user_id = uid()
  AND (
        t.transacted_at < $2
        OR (t.transacted_at = $2 AND t.id < $3)
      )
ORDER BY t.transacted_at DESC, t.id DESC
LIMIT 20;
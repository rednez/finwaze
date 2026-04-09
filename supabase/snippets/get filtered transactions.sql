select * from get_filtered_transactions(
  -- p_category_ids BIGINT[] DEFAULT NULL
  ARRAY[]::bigint[],
  -- p_account_ids BIGINT[] DEFAULT NULL
  null,
  -- p_charged_currency_codes TEXT[] DEFAULT NULL
  null,
  -- p_transaction_currency_codes TEXT[] DEFAULT NULL
  null,
  -- p_transaction_type transactions.type % type DEFAULT NULL
  null,
  -- p_month DATE DEFAULT NULL
  '2026-02-01',
  -- p_page INTEGER DEFAULT 1
  null,
  -- p_page_size INTEGER DEFAULT NULL
  null
  );
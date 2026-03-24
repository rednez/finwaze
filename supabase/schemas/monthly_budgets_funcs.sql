-- Returns total planned budget per category for the current month, filtered by currency.
CREATE OR REPLACE FUNCTION get_current_month_budgets_by_category (
  p_currency_code TEXT
) returns TABLE (
  category_name TEXT,
  total_budget NUMERIC
) language sql
SET
  search_path = '' AS $$
  select
    cat.name as category_name,
    sum(mb.planned_amount) as total_budget
  from public.monthly_budgets mb
  join public.categories cat
    on cat.id = mb.category_id
  join public.currencies cur
    on cur.id = mb.currency_id
  where cur.code = p_currency_code
    and mb.budget_month = date_trunc('month', now()::timestamp)::date
  group by cat.name
  order by total_budget desc, category_name asc;
$$;

-- Returns planned and spent amounts per expense group for a given month and currency.
-- Includes groups with spending but no budget (is_unplanned = true).
CREATE OR REPLACE FUNCTION public.get_monthly_budgets_by_groups(
  p_month         DATE,
  p_currency_code TEXT
)
RETURNS TABLE (
  group_id         BIGINT,
  group_name       TEXT,
  planned_amount   NUMERIC,
  spent_amount     NUMERIC,
  categories_count BIGINT,
  is_unplanned     BOOLEAN
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  budgets AS (
    SELECT
      g.id                           AS group_id,
      g.name                         AS group_name,
      SUM(mb.planned_amount)         AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories      cat ON cat.id       = mb.category_id
    JOIN public.groups          g   ON g.id         = cat.group_id
    JOIN public.currencies      cur ON cur.id        = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND g.is_system     = false
    GROUP BY g.id, g.name
  ),
  spending AS (
    SELECT
      g.id                      AS group_id,
      g.name                    AS group_name,
      SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code  = p_currency_code
      AND t.type    = 'expense'::public.transaction_type
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY g.id, g.name
  ),
  categories_count AS (
    SELECT
      cat.group_id,
      COUNT(DISTINCT combined.category_id) AS categories_count
    FROM (
      SELECT mb.category_id
      FROM public.monthly_budgets mb
      JOIN public.categories cat ON cat.id  = mb.category_id
      JOIN public.groups     g   ON g.id    = cat.group_id
      JOIN public.currencies cur ON cur.id  = mb.currency_id
      CROSS JOIN month_start ms
      WHERE cur.code       = p_currency_code
        AND mb.budget_month = ms.val::DATE
        AND g.is_system     = false

      UNION

      SELECT t.category_id
      FROM public.transactions t
      JOIN public.categories cat ON cat.id = t.category_id
      JOIN public.groups     g   ON g.id   = cat.group_id
      JOIN public.currencies cur ON cur.id = t.transaction_currency_id
      CROSS JOIN month_start ms
      WHERE cur.code  = p_currency_code
        AND t.type    = 'expense'::public.transaction_type
        AND g.is_system = false
        AND (t.transacted_at + t.local_offset) >= ms.val
        AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    ) AS combined(category_id)
    JOIN public.categories cat ON cat.id = combined.category_id
    GROUP BY cat.group_id
  )
SELECT
  COALESCE(b.group_id,   s.group_id)    AS group_id,
  COALESCE(b.group_name, s.group_name)  AS group_name,
  COALESCE(b.planned_amount,   0)       AS planned_amount,
  COALESCE(s.spent_amount,     0)       AS spent_amount,
  COALESCE(cc.categories_count, 0)      AS categories_count,
  (b.group_id IS NULL)                  AS is_unplanned
FROM budgets  b
FULL OUTER JOIN spending s ON s.group_id = b.group_id
LEFT JOIN categories_count cc ON cc.group_id = COALESCE(b.group_id, s.group_id)
ORDER BY b.planned_amount DESC NULLS LAST, COALESCE(b.group_name, s.group_name);
$$;

-- Returns the total planned budget and total actual spending for a given month and currency.
CREATE OR REPLACE FUNCTION public.get_monthly_budget_totals(
  p_month         DATE,
  p_currency_code TEXT
)
RETURNS TABLE (
  planned_amount NUMERIC,
  spent_amount   NUMERIC
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  budgets AS (
    SELECT SUM(mb.planned_amount) AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories      cat ON cat.id  = mb.category_id
    JOIN public.groups          g   ON g.id    = cat.group_id
    JOIN public.currencies      cur ON cur.id  = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND g.is_system     = false
  ),
  spending AS (
    SELECT -SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code   = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  )
SELECT
  COALESCE(b.planned_amount, 0) AS planned_amount,
  COALESCE(s.spent_amount,   0) AS spent_amount
FROM budgets b, spending s;
$$;

-- Returns expense totals per group for the selected month and the previous month, 
-- filtered by currency.
-- Used for month-over-month spending comparison across groups.
CREATE OR REPLACE FUNCTION public.get_monthly_expenses_by_groups(
  p_month         DATE,
  p_currency_code TEXT
)
RETURNS TABLE (
  group_id                BIGINT,
  group_name              TEXT,
  selected_month_amount   NUMERIC,
  previous_month_amount   NUMERIC
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  selected_month AS (
    SELECT
      g.id                        AS group_id,
      g.name                      AS group_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND g.is_system          = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY g.id, g.name
  ),
  previous_month AS (
    SELECT
      g.id                        AS group_id,
      g.name                      AS group_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.groups       g   ON g.id   = cat.group_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND g.is_system          = false
      AND (t.transacted_at + t.local_offset) >= ms.val - INTERVAL '1 month'
      AND (t.transacted_at + t.local_offset) <  ms.val
    GROUP BY g.id, g.name
  )
SELECT
  COALESCE(s.group_id,   p.group_id)   AS group_id,
  COALESCE(s.group_name, p.group_name) AS group_name,
  COALESCE(s.amount, 0)                AS selected_month_amount,
  COALESCE(p.amount, 0)                AS previous_month_amount
FROM selected_month s
LEFT JOIN previous_month p ON p.group_id = s.group_id
ORDER BY selected_month_amount DESC, s.group_name;
$$;

-- Returns total planned budget and total actual spending for a specific group,
-- given month and currency.
CREATE OR REPLACE FUNCTION public.get_monthly_budget_totals_by_group(
  p_month         DATE,
  p_currency_code TEXT,
  p_group_id      BIGINT
)
RETURNS TABLE (
  planned_amount NUMERIC,
  spent_amount   NUMERIC
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  budgets AS (
    SELECT SUM(mb.planned_amount) AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories      cat ON cat.id  = mb.category_id
    JOIN public.currencies      cur ON cur.id  = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND cat.group_id    = p_group_id
  ),
  spending AS (
    SELECT -SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code   = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND cat.group_id = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
  )
SELECT
  COALESCE(b.planned_amount, 0) AS planned_amount,
  COALESCE(s.spent_amount,   0) AS spent_amount
FROM budgets b, spending s;
$$;

-- Returns expense totals per category within a specific group for the selected month
-- and the previous month, filtered by currency.
-- Used for month-over-month spending comparison across categories in a group.
CREATE OR REPLACE FUNCTION public.get_monthly_expenses_by_categories(
  p_month         DATE,
  p_currency_code TEXT,
  p_group_id      BIGINT
)
RETURNS TABLE (
  category_id             BIGINT,
  category_name           TEXT,
  selected_month_amount   NUMERIC,
  previous_month_amount   NUMERIC
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  selected_month AS (
    SELECT
      cat.id                      AS category_id,
      cat.name                    AS category_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND cat.group_id           = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY cat.id, cat.name
  ),
  previous_month AS (
    SELECT
      cat.id                      AS category_id,
      cat.name                    AS category_name,
      -SUM(t.transaction_amount)  AS amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code             = p_currency_code
      AND t.type NOT IN ('transfer'::public.transaction_type, 'internal'::public.transaction_type)
      AND t.transaction_amount < 0
      AND cat.group_id           = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val - INTERVAL '1 month'
      AND (t.transacted_at + t.local_offset) <  ms.val
    GROUP BY cat.id, cat.name
  )
SELECT
  COALESCE(s.category_id,   p.category_id)   AS category_id,
  COALESCE(s.category_name, p.category_name) AS category_name,
  COALESCE(s.amount, 0)                      AS selected_month_amount,
  COALESCE(p.amount, 0)                      AS previous_month_amount
FROM selected_month s
LEFT JOIN previous_month p ON p.category_id = s.category_id
ORDER BY selected_month_amount DESC, s.category_name;
$$;

-- Returns planned and spent amounts per category within a specific group
-- for a given month and currency.
-- Includes categories with spending but no budget (is_unplanned = true).
CREATE OR REPLACE FUNCTION public.get_monthly_budgets_by_categories(
  p_month         DATE,
  p_currency_code TEXT,
  p_group_id      BIGINT
)
RETURNS TABLE (
  category_id    BIGINT,
  category_name  TEXT,
  planned_amount NUMERIC,
  spent_amount   NUMERIC,
  is_unplanned   BOOLEAN
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT date_trunc('month', p_month::TIMESTAMP) AS val
  ),
  budgets AS (
    SELECT
      cat.id                 AS category_id,
      cat.name               AS category_name,
      SUM(mb.planned_amount) AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories      cat ON cat.id = mb.category_id
    JOIN public.currencies      cur ON cur.id = mb.currency_id
    CROSS JOIN month_start      ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND cat.group_id    = p_group_id
    GROUP BY cat.id, cat.name
  ),
  spending AS (
    SELECT
      cat.id                    AS category_id,
      cat.name                  AS category_name,
      SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories   cat ON cat.id = t.category_id
    JOIN public.currencies   cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start   ms
    WHERE cur.code   = p_currency_code
      AND t.type     = 'expense'::public.transaction_type
      AND cat.group_id = p_group_id
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY cat.id, cat.name
  )
SELECT
  COALESCE(b.category_id,   s.category_id)   AS category_id,
  COALESCE(b.category_name, s.category_name) AS category_name,
  COALESCE(b.planned_amount, 0)              AS planned_amount,
  COALESCE(s.spent_amount,   0)              AS spent_amount,
  (b.category_id IS NULL)                    AS is_unplanned
FROM budgets  b
FULL OUTER JOIN spending s ON s.category_id = b.category_id
ORDER BY b.planned_amount DESC NULLS LAST, COALESCE(b.category_name, s.category_name);
$$;

-- Returns budgets and spending per category for a given month and currency.
-- Includes group info, previous month planned and spent amounts for comparison.
-- Unplanned categories (spending without a budget) are included with is_unplanned = true.
-- All monetary amounts are returned as positive numbers.
CREATE OR REPLACE FUNCTION public.get_monthly_budgets_detailed(
  p_month         DATE,
  p_currency_code TEXT
)
RETURNS TABLE (
  category_id              BIGINT,
  category_name            TEXT,
  group_id                 BIGINT,
  group_name               TEXT,
  planned_amount           NUMERIC,
  previous_planned_amount  NUMERIC,
  spent_amount             NUMERIC,
  previous_spent_amount    NUMERIC,
  is_unplanned             BOOLEAN
)
LANGUAGE sql
STABLE
SET search_path = ''
AS $$
WITH
  month_start AS (
    SELECT
      date_trunc('month', p_month::TIMESTAMP)                      AS val,
      date_trunc('month', p_month::TIMESTAMP) - INTERVAL '1 month' AS prev_val
  ),

  -- Budgets for the selected month
  budgets AS (
    SELECT
      cat.id    AS category_id,
      cat.name  AS category_name,
      g.id      AS group_id,
      g.name    AS group_name,
      SUM(mb.planned_amount) AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories cat ON cat.id  = mb.category_id
    JOIN public.groups     g   ON g.id    = cat.group_id
    JOIN public.currencies cur ON cur.id  = mb.currency_id
    CROSS JOIN month_start ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.val::DATE
      AND g.is_system     = false
    GROUP BY cat.id, cat.name, g.id, g.name
  ),

  -- Budgets for the previous month
  prev_budgets AS (
    SELECT
      cat.id                 AS category_id,
      SUM(mb.planned_amount) AS planned_amount
    FROM public.monthly_budgets mb
    JOIN public.categories cat ON cat.id  = mb.category_id
    JOIN public.groups     g   ON g.id    = cat.group_id
    JOIN public.currencies cur ON cur.id  = mb.currency_id
    CROSS JOIN month_start ms
    WHERE cur.code       = p_currency_code
      AND mb.budget_month = ms.prev_val::DATE
      AND g.is_system     = false
    GROUP BY cat.id
  ),

  -- Actual spending for the selected month
  spending AS (
    SELECT
      cat.id                    AS category_id,
      cat.name                  AS category_name,
      g.id                      AS group_id,
      g.name                    AS group_name,
      SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories  cat ON cat.id = t.category_id
    JOIN public.groups      g   ON g.id   = cat.group_id
    JOIN public.currencies  cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start  ms
    WHERE cur.code    = p_currency_code
      AND t.type      = 'expense'::public.transaction_type
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.val
      AND (t.transacted_at + t.local_offset) <  ms.val + INTERVAL '1 month'
    GROUP BY cat.id, cat.name, g.id, g.name
  ),

  -- Actual spending for the previous month
  prev_spending AS (
    SELECT
      cat.id                    AS category_id,
      SUM(t.transaction_amount) AS spent_amount
    FROM public.transactions t
    JOIN public.categories  cat ON cat.id = t.category_id
    JOIN public.groups      g   ON g.id   = cat.group_id
    JOIN public.currencies  cur ON cur.id = t.transaction_currency_id
    CROSS JOIN month_start  ms
    WHERE cur.code    = p_currency_code
      AND t.type      = 'expense'::public.transaction_type
      AND g.is_system = false
      AND (t.transacted_at + t.local_offset) >= ms.prev_val
      AND (t.transacted_at + t.local_offset) <  ms.val
    GROUP BY cat.id
  )

SELECT
  COALESCE(b.category_id,   s.category_id)   AS category_id,
  COALESCE(b.category_name, s.category_name) AS category_name,
  COALESCE(b.group_id,      s.group_id)      AS group_id,
  COALESCE(b.group_name,    s.group_name)    AS group_name,
  COALESCE(b.planned_amount,  0)             AS planned_amount,
  COALESCE(pb.planned_amount, 0)             AS previous_planned_amount,
  ABS(COALESCE(s.spent_amount,  0))          AS spent_amount,
  ABS(COALESCE(ps.spent_amount, 0))          AS previous_spent_amount,
  (b.category_id IS NULL)                    AS is_unplanned
FROM budgets b
FULL OUTER JOIN spending     s  ON s.category_id  = b.category_id
LEFT  JOIN prev_budgets      pb ON pb.category_id = COALESCE(b.category_id, s.category_id)
LEFT  JOIN prev_spending     ps ON ps.category_id = COALESCE(b.category_id, s.category_id)
ORDER BY
  b.planned_amount DESC NULLS LAST,
  COALESCE(b.group_name, s.group_name),
  COALESCE(b.category_name, s.category_name);
$$;
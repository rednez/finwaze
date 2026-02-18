CREATE OR REPLACE VIEW my_accounts
WITH
  (security_invoker = ON) AS
SELECT
  acc.id,
  acc.name,
  c.code AS currency_code
FROM
  accounts acc
  JOIN currencies c ON c.id = acc.currency_id;

CREATE OR REPLACE VIEW my_categories
WITH
  (security_invoker = ON) AS
SELECT
  cat.id,
  cat.name,
  grp.id AS group_id,
  grp.name AS group_name
FROM
  categories cat
  JOIN groups grp ON grp.id = cat.group_id;
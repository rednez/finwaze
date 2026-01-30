create or replace view transactions_view AS
SELECT transactions.id, transactions.created_at, budget_month, transaction_amount, currencies.code as transaction_currency, groups.name as group, categories.name as category
FROM transactions
LEFT join currencies on currencies.id = transactions.transaction_currency_id
left join categories on categories.id = transactions.category_id 
left join groups on groups.id = categories.group_id
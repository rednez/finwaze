select planned_amount, budget_month, cat.name as category_name, gr.name as group_name from monthly_budgets mb
join categories cat on cat.id = mb.category_id
join groups gr on gr.id = cat.group_id;
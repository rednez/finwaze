select cat.id, cat.name, gr.id as group_id, gr.name as group_name from categories cat
join groups gr on gr.id = cat.group_id
WHERE gr.is_system IS NOT TRUE

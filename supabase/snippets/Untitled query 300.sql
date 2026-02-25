create policy "Enable update for owner only" on "public"."monthly_budgets" as PERMISSIVE
for update
  to authenticated using (
    (
      user_id = (
        select
          auth.uid () as uid
      )
    )
  );
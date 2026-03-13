
  create policy "Enable delete for users based on user_id"
  on "public"."transactions"
  as permissive
  for delete
  to public
using ((( SELECT auth.uid() AS uid) = user_id));




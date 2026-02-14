UPDATE auth.users
SET email_change_token_new = ''
WHERE email = 'demo@mail.com' AND email_change_token_new IS NULL;
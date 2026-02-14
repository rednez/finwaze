INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  email_change,
  email_change_token_new,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'demo@mail.com',
  '',
  '',
  crypt('password1234', gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}',
  '{"full_name": "Demo User"}',
  now(),
  now(),
  '',
  ''
);

INSERT INTO auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  provider_id,
  last_sign_in_at,
  created_at,
  updated_at
) VALUES (
  gen_random_uuid(),
  (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
  jsonb_build_object('sub', (SELECT id FROM auth.users WHERE email = 'demo@mail.com'), 'email', 'demo@mail.com'),
  'email',
  (SELECT id FROM auth.users WHERE email = 'demo@mail.com'),
  now(),
  now(),
  now()
);


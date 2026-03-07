CREATE TYPE account_type AS ENUM ('regular', 'savings_goal');

CREATE TYPE transaction_type AS ENUM ('income', 'expense', 'internal', 'transfer');

CREATE TYPE savings_goal_status AS ENUM ('not_started', 'in_progress', 'done', 'cancelled');
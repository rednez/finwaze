INSERT INTO groups
            (user_id,
             NAME,
             transaction_type)
VALUES      ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Різне',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Кредити',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Податки',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Благодійність',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Здоровʼя',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Охорона',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Послуги',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Освіта',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Автомобіль',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Життя',
              'expense' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Основний дохід',
              'income' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Інший дохід',
              'income' );
            

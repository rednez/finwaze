INSERT INTO accounts
            (user_id,
             NAME,
             currency_id)
VALUES      ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Demo Account USD',
              (SELECT id
               FROM   currencies
               WHERE  code = 'USD') ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Demo Account UAH',
              (SELECT id
               FROM   currencies
               WHERE  code = 'UAH') ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Demo Account EUR',
              (SELECT id
               FROM   currencies
               WHERE  code = 'EUR') ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Moneta',
              (SELECT id
               FROM   currencies
               WHERE  code = 'CZK') ); 
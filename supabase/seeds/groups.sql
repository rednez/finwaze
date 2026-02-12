INSERT INTO groups
            (user_id,
             NAME)
VALUES      ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Різне' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Кредити' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Податки' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Благодійність' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Здоровʼя' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Охорона' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Послуги' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Освіта' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Автомобіль' ),
            ( (SELECT id
               FROM   auth.users
               WHERE  email = 'demo@mail.com'),
              'Життя' );
            

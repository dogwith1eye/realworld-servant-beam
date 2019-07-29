BEGIN;

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  password TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE NOT NULL,
  bio TEXT NOT NULL,
  image TEXT
);

COMMIT;

BEGIN;

INSERT INTO users
(id
,password
,email
,username
,bio)
VALUES
(1
,'test'
,'mdoig@conduit.com'
,'mdoig'
,'Code Monkey at Conduit');

COMMIT;
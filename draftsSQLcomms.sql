-- NB - we treat table instance as state, thus we mus tenforce same structure

DROP TABLE IF EXISTS draft_storage;
DROP TABLE IF EXISTS published_posts;

CREATE TABLE draft_storage (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  edited_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE published_posts (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  edited_at TIMESTAMP DEFAULT NOW(),
  is_active BOOLEAN DEFAULT TRUE
);

-- or alter

ALTER TABLE draft_storage 
ADD COLUMN edited_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

ALTER TABLE published_posts 
ADD COLUMN edited_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

ALTER TABLE edit_draft ADD COLUMN created_at TIMESTAMP DEFAULT NOW();

-- later define clear baselines - now just racking needed changes

ALTER TABLE draft_storage ADD CONSTRAINT max_posts CHECK (
  (SELECT COUNT(*) FROM draft_storage) < 2
);

-- full db-stored procedure to trigger draft example cleanup <------- also needs scripting for SETUP

CREATE OR REPLACE FUNCTION delete_all_posts()
RETURNS void AS $$
BEGIN
  DELETE FROM draft_storage;
  DELETE FROM edit_draft;
  DELETE FROM published_posts;
END;
$$ LANGUAGE plpgsql;



-- fix now

DROP TABLE IF EXISTS draft_storage;
DROP TABLE IF EXISTS published_posts;

CREATE TABLE draft_storage (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  edited_at TIMESTAMP DEFAULT NULL,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE published_posts (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  edited_at TIMESTAMP DEFAULT NULL,
  is_active BOOLEAN DEFAULT TRUE
);



-- prev

CREATE TABLE draft_storage (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE edit_draft (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  edited_at TIMESTAMP DEFAULT NOW()
);

-- combine with constraint as can edit 1 post at a time - std feature
ALTER TABLE edit_draft ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- also need this:
CREATE UNIQUE INDEX single_active_edit ON edit_draft (is_active) WHERE is_active = TRUE;



CREATE TABLE published_posts (
  id SERIAL PRIMARY KEY,
  content TEXT NOT NULL,
  published_at TIMESTAMP DEFAULT NOW()
);

-- structure and process later

-- agent locking
ALTER TABLE edit_draft ADD COLUMN lock_status BOOLEAN DEFAULT FALSE;
ALTER TABLE edit_draft ADD COLUMN locked_by VARCHAR(255) DEFAULT NULL;

-- enforce lock in transactions
UPDATE edit_draft 
SET lock_status = TRUE, locked_by = 'demo_script'
WHERE id = (SELECT id FROM edit_draft WHERE lock_status = FALSE LIMIT 1)
RETURNING *;

-- adjust by actual flows
-- the system cares about where content lives, not what the content is


-- button logic to control buttons state
SELECT 
  EXISTS(SELECT 1 FROM edit_draft) AS in_edit_mode,
  EXISTS(SELECT 1 FROM draft_storage) AS in_draft_mode,
  EXISTS(SELECT 1 FROM published_posts) AS in_published_mode;

-- atomic moving rough example
WITH moved AS (
  DELETE FROM edit_draft RETURNING *
)
INSERT INTO draft_storage (id, content, created_at)
SELECT id, content, created_at FROM moved;

-- ----------------- tables for access

DROP TABLE IF EXISTS rejections;
DROP TABLE IF EXISTS interests;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE interests (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interested_in INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_interest UNIQUE (user_id, interested_in)
);

CREATE TABLE rejections (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rejected_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_rejection UNIQUE (user_id, rejected_id)
);

--  examples scenarios - WILL ADJUST BELOW FOR EASIER FOLLOWING

-- DB state 1

INSERT INTO users (username)
VALUES ('A'), ('B'), ('C'), ('D'), ('E');

INSERT INTO interests (user_id, interested_in) 
VALUES
  (1, 2),  -- A -> B
  (2, 3),  -- B -> C
  (1, 3),  -- A -> C
  (3, 1),  -- C -> A
  (1, 4);  -- A -> D

INSERT INTO rejections (user_id, rejected_id)
VALUES
  (4, 1),  -- D rejects A
  (2, 4),  -- B rejects D
  (4, 5),  -- D rejects E
  (5, 4);  -- E rejects D

-- adjusted:

INSERT INTO users (username)
VALUES ('A'), ('B');

INSERT INTO interests (user_id, interested_in) 
VALUES
  (1, 2);

-- DB state 2 - needs new tables with different name, if a clean example - NB NEED TO SCRIPT ALL INTO the working example

CREATE TABLE users2 (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE interests2 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interested_in INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_interest2 UNIQUE (user_id, interested_in)
);

CREATE TABLE rejections2 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rejected_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_rejection2 UNIQUE (user_id, rejected_id)
);

INSERT INTO users2 (username)
VALUES ('A'), ('B');

INSERT INTO interests2 (user_id, interested_in) 
VALUES
  (1, 2), (2, 1);


-- DBN state 3

CREATE TABLE users3 (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE interests3 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  interested_in INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_interest3 UNIQUE (user_id, interested_in)
);

CREATE TABLE rejections3 (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rejected_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT unique_rejection3 UNIQUE (user_id, rejected_id)
);

INSERT INTO users3 (username)
VALUES ('A'), ('B');

INSERT INTO interests3 (user_id, interested_in) 
VALUES
  (1, 2);

INSERT INTO rejections3 (user_id, rejected_id)
VALUES
  (2, 1);



-- -----------------------------------
-- -----------------------------------
-- -----------------------------------

-- Admin example

CREATE TABLE users_access (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE
);

CREATE TABLE admins (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users_access(id) ON DELETE CASCADE,
  owns_space TEXT NOT NULL
);

CREATE TABLE spaces (
  id SERIAL PRIMARY KEY,
  space_name TEXT NOT NULL UNIQUE
);

CREATE TABLE permissions (
  id SERIAL PRIMARY KEY,
  space TEXT REFERENCES spaces(space_name) ON DELETE CASCADE,
  user_with_access INT REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE permissions_log (
  id SERIAL PRIMARY KEY,
  admin_user INT REFERENCES users_access(id) ON DELETE CASCADE,
  granted_user INT REFERENCES users_access(id) ON DELETE CASCADE,
  space TEXT REFERENCES spaces(space_name) ON DELETE CASCADE,
  timestamp TIMESTAMP DEFAULT NOW()
);

INSERT INTO users_access (username) VALUES 
('A'),
('B');

INSERT INTO spaces (space_name) VALUES 
('A1');

INSERT INTO admins (user_id, owns_space) 
VALUES ((SELECT id FROM users_access WHERE username = 'A'), 'A1');

INSERT INTO permissions (space, user_with_access)
VALUES ('A1', (SELECT id FROM users WHERE username = 'B'));

INSERT INTO permissions_log (admin_user, granted_user, space)
VALUES (
  (SELECT id FROM users_access WHERE username = 'A'),
  (SELECT id FROM users_access WHERE username = 'B'),
  'A1'  
);
-- set up test data

CREATE TABLE movies (
  movieId INTEGER PRIMARY KEY,
  title TEXT,
  genres TEXT  -- pipe-separated
);

CREATE TABLE ratings (
  userId INTEGER,
  movieId INTEGER,
  rating NUMERIC(2,1),
  timestamp BIGINT,
  PRIMARY KEY (userId, movieId),
  FOREIGN KEY (movieId) REFERENCES movies(movieId)
);

-- data from MovieLens

\copy movies(movieId, title, genres)
  FROM './zzzzz_exampledata/movies.csv'
  DELIMITER ',' CSV HEADER;

\copy ratings(userId, movieId, rating, timestamp)
  FROM './zzzzz_exampledata/ratings.csv'
  DELIMITER ',' CSV HEADER;

-- Checking that it worked:

SELECT COUNT(*) FROM movies; -- or just *
SELECT COUNT(*) FROM ratings; -- or just *

-- or just chekc you have tables with:

\dt


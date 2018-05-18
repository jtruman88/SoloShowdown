CREATE TABLE players (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE matches (
  id serial PRIMARY KEY,
  player_id int NOT NULL REFERENCES players (id),
  placement int NOT NULL,
  eliminations int NOT NULL
);

CREATE TABLE players (
  id serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE points (
  id serial PRIMARY KEY,
  place int4range,
  point_value int
);

CREATE TABLE matches (
  id serial PRIMARY KEY,
  player_id int NOT NULL REFERENCES players (id),
  point_id int NOt NULL REFERENCES points (id),
  placement int NOT NULL,
  eliminations int NOT NULL,
  date_played timestamp DEFAULT NOW()
);


INSERT INTO points (place, point_value) VALUES
('[1,1]', 100), ('[2,2]', 94), ('[3,3]', 91),
('[4,4]', 88), ('[5,5]', 85), ('[6,6]', 80),
('[7,7]', 75), ('[8,8]', 70), ('[9,9]', 65),
('[10,10]', 60), ('[11,15]', 55), ('[16,20]', 50),
('[21,30]', 45), ('[31,40]', 40), ('[41,50]', 35), 
('[51,75]', 30), ('[76,100]', 25);
require 'pg'

class DatabasePersistence
  def initialize
    @db = connect_to_database
  end
  
  def disconnect
    db.close
  end
  
  def query(statement, *params)
    db.exec_params(statement, params)
  end
  
  def get_players
    sql = <<~SQL
      SELECT * FROM players;
    SQL
    
    result = query(sql)
    
    result.map do |tuple|
      { name: tuple['name'], id: tuple['id'] }
    end
  end
  
  def add_player(name)
    sql = "INSERT INTO players (name) VALUES ($1);"
    query(sql, name)
  end
  
  def get_leaderboard_stats
    sql = <<~SQL
       SELECT matches.player_id, players.name AS name, COUNT(matches.player_id) AS matches_played,
      (SELECT winners FROM (SELECT player_id, COUNT(placement) AS winners FROM matches WHERE placement = 1 GROUP BY player_id) AS win_count WHERE win_count.player_id = matches.player_id) AS wins,
      ROUND(AVG(matches.placement)) AS avg_place, SUM(points.point_value) AS total_points,
      SUM(matches.eliminations) AS total_elim, ROUND(AVG(matches.eliminations)) AS avg_elim
      FROM players JOIN matches ON players.id = matches.player_id
      JOIN points ON points.id = matches.point_id
      GROUP BY players.name, matches.player_id
      ORDER BY total_points DESC;
    SQL
    
    result = query(sql)
    
    result.map do |tuple|
      leaderboard_hash(tuple)
    end
  end
  
  def get_overall_stats(id)
    sql = <<~SQL
      SELECT players.name AS name, COUNT(matches.player_id) AS matches_played,
      (SELECT COUNT(placement) FROM matches WHERE placement = 1 AND player_id = $1) AS wins,
      ROUND(AVG(matches.placement)) AS avg_place, SUM(points.point_value) AS total_points,
      SUM(matches.eliminations) AS total_elim, ROUND(AVG(matches.eliminations)) AS avg_elim
      FROM players JOIN matches ON players.id = matches.player_id
      JOIN points ON points.id = matches.point_id
      WHERE players.id = $1
      GROUP BY players.name
      ORDER BY total_points;
    SQL
    
    result = query(sql, id)
    
    result.map do |tuple|
      leaderboard_hash(tuple)
    end
  end
  
  def get_player_matches(id)
    sql = <<~SQL
      SELECT matches.placement, points.point_value, 
      matches.eliminations
      FROM matches JOIN points
      ON points.id = matches.point_id
      WHERE matches.player_id = $1
      ORDER BY date_played;
    SQL
    
    result = query(sql, id)
    
    result.map do |tuple|
      match_stats(tuple)
    end
  end
  
  def add_match_data(player_id, placement, elims)
    point_id = get_point_id(placement)
    
    sql = <<~SQL
      INSERT INTO matches
      (player_id, point_id, placement, eliminations)
      VALUES ($1, $2, $3, $4);
    SQL
    
    query(sql, player_id, point_id, placement, elims)
  end
  
  def get_player_name(id)
    sql = "SELECT name FROM players WHERE $1 = id;"
    
    result = query(sql, id)
    
    result.map { |tuple| tuple['name'] }.first
  end
  
  private
  
  attr_reader :db
  
  def connect_to_database
    if Sinatra::Base.production?
      PG.connect(ENV['DATABASE_URL'])
    else
      PG.connect(dbname: "solo_test")
    end
  end
  
  def leaderboard_hash(tuple)
    { name: tuple['name'],
      matches: tuple['matches_played'].to_i,
      wins: tuple['wins'].to_i,
      avg_place: tuple['avg_place'].to_i,
      points: tuple['total_points'].to_i,
      total_elim: tuple['total_elim'].to_i,
      avg_elim: tuple['avg_elim'].to_i }
  end
  
  def match_stats(tuple)
    { place: tuple['placement'],
      points: tuple['point_value'],
      elims: tuple['eliminations'] }
  end
  
  def get_point_id(placement)
    sql = "SELECT id FROM points WHERE ($1)::integer <@ place;"
    result = query(sql, placement)
    result.map { |tuple| tuple['id'] }.first.to_i
  end
end
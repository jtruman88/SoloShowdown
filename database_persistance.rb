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
  end
  
  private
  
  attr_reader :db
end
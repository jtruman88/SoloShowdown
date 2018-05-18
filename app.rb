require 'sinatra'
require 'sinatra/content_for'
require 'tilt/erubis'

require_relative "database_persistence"

configure do
  enable :sessions
  set :session_secret, 'secret'
  set :erb, :escape_html => true
end

configure(:development) do
  require 'sinatra/reloader'
  also_reload "database_persistence.rb"
end

before do
  @data = DatabasePersistence.new
end

after do
  @data.disconnect
end

get '/' do
  redirect '/players'
end

# Lists all players
get '/players' do
  @players = @data.get_players
  erb :player_list
end

# Adds a new player
post '/player' do
  
  redirect '/players'
end

get '/players/leaderboard' do
  
  erb :leaderboard
end

# Lists a player's stats
get '/players/:player_id' do
  
  erb :player
end

# Displays the form to add match data
get '/players/:player_id/add_match' do
  
  erb :add_match
end

# Add match data to player's stats
post '/players/:player_id/add' do
  
  redirect "/players/#{player_id}"
end
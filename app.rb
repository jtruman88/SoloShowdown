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

def valid_name?(name)
  name.length >= 1
end

def valid_match_data?(placement, elims)
  if placement <= 0 || placement > 100
    session[:error] = "Placement must be between 1 and 100."
    return false
  elsif elims < 0 || elims > 99
    session[:error] = "Eliminations must be between 0 and 99."
    return false
  end
  
  true
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
  name = params[:player_name].strip
  
  if valid_name?(name)
    @data.add_player(name)
    session[:success] = "Nice! You've been added!"
    redirect '/players'
  else
    session[:error] = "Sorry... your name cannot be blank."
    @players = @data.get_players
    erb :player_list
  end
end

# Display leaderboard table for all players
get '/players/leaderboard' do
  @players_data = @data.get_leaderboard_stats
  
  erb :leaderboard
end

# Lists a player's stats
get '/players/:player_id' do
  @player_id = params[:player_id].to_i
  @overall_stats = @data.get_overall_stats(@player_id)
  @player_name = @data.get_player_name(@player_id)
  @match_stats = @data.get_player_matches(@player_id)
  
  erb :player
end

# Displays the form to add match data
get '/players/:player_id/add_match' do
  @player_id = params[:player_id]
  
  erb :add_match
end

# Add match data to player's stats
post '/players/:player_id/add' do
  @player_id = params[:player_id].to_i
  placement = params[:placement].to_i
  elims = params[:eliminations].to_i
  
  if valid_match_data?(placement, elims)
    session[:success] = "Match data was successfully added!"
    @data.add_match_data(@player_id, placement, elims)
    redirect "/players/#{@player_id}"
  else
    erb :add_match
  end
end
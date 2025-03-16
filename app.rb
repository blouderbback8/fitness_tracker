require 'sinatra'
require 'sqlite3'
require 'json'
require 'date'

# Set up Sinatra to serve static files from the public directory
set :public_folder, File.expand_path('public', __dir__)

# Create or open the SQLite database
DB = SQLite3::Database.new "fitness_tracker.db"
DB.results_as_hash = true  # Allows hash-style results

# Ensure the database has the required tables
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS indulgences (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    date TEXT NOT NULL
  );
SQL

DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS workouts (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    date TEXT NOT NULL,
    duration INTEGER NOT NULL
  );
SQL

# Route to show the home page
get '/' do
  @workouts = DB.execute("SELECT * FROM workouts")
  @indulgences = DB.execute("SELECT * FROM indulgences")

  # Convert workouts to a hash grouped by date for calendar display
  @workouts_by_date = @workouts.group_by { |w| w["date"] }
  @indulgences_by_date = @indulgences.group_by { |i| i["date"] }

  puts "Rendering index.erb"
  erb :index
end

# Route to show the day planner page
get '/day_planner' do
  erb :day_planner
end

# Route to add a new workout
post '/add_workout' do
  DB.execute("INSERT INTO workouts (name, date, duration) VALUES (?, ?, ?)",
             [params[:name], params[:date], params[:duration]])
  redirect '/'
end

# Route to add a new indulgence (forces cardio the next day)
post '/add_indulgence' do
  indulgence_name = params[:name]
  indulgence_date = params[:date]
  
  # Insert the indulgence into the database
  DB.execute("INSERT INTO indulgences (name, date) VALUES (?, ?)", [indulgence_name, indulgence_date])
  
  # If indulgence requires cardio, force cardio the next day
  if ["Alcohol", "Dessert", "Fast Food"].include?(indulgence_name)
    next_day = (Date.parse(indulgence_date) + 1).to_s
    DB.execute("INSERT INTO workouts (name, date, duration) VALUES ('Cardio', ?, 30)", [next_day])
  end

  redirect '/'
end

# Route to update workout or indulgence date when dragged
post '/update_date' do
  data = JSON.parse(request.body.read)
  if data["type"] == "workout"
    DB.execute("UPDATE workouts SET date = ? WHERE id = ?", [data["date"], data["id"]])
  else
    DB.execute("UPDATE indulgences SET date = ? WHERE id = ?", [data["date"], data["id"]])
  end
  status 200
end

# Route to debug and view database contents
get '/debug_db' do
  workouts = DB.execute("SELECT * FROM workouts")
  indulgences = DB.execute("SELECT * FROM indulgences")

  content_type :json
  { workouts: workouts, indulgences: indulgences }.to_json
end

# Explicit routes for CSS and JS
get '/css/style.css' do
  content_type 'text/css'
  send_file File.join(settings.public_folder, 'css', 'style.css')
end

get '/calendar.js' do
  content_type 'application/javascript'
  send_file File.join(settings.public_folder, 'calendar.js')
end

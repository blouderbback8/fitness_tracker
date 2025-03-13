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

# Route to add a new workout (Prevents Jiu-Jitsu after Alcohol)
post '/add_workout' do
  name = params[:name]
  date = params[:date]
  duration = params[:duration]

  # Check if the user drank alcohol the day before
  parsed_date = Date.parse(date)
  previous_date = parsed_date - 1
  drank_yesterday = DB.execute("SELECT * FROM indulgences WHERE name = 'Alcohol' AND date = ?", [previous_date.to_s]).any?

  if name == "Jiu-Jitsu" && drank_yesterday
    halt 400, "🚫 You drank alcohol yesterday. No Jiu-Jitsu today."
  end

  DB.execute("INSERT INTO workouts (name, date, duration) VALUES (?, ?, ?)", [name, date, duration])
  redirect '/'
end

# Route to add a new indulgence
post '/add_indulgence' do
  DB.execute("INSERT INTO indulgences (name, date) VALUES (?, ?)", [params[:name], params[:date]])
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

# 🔥 Route to delete a workout or indulgence (Drag-and-drop trash bin feature)
post '/delete_item' do
  request_data = JSON.parse(request.body.read)
  id = request_data["id"]
  type = request_data["type"]

  if type == "workout"
    DB.execute("DELETE FROM workouts WHERE id = ?", [id])
  elsif type == "indulgence"
    DB.execute("DELETE FROM indulgences WHERE id = ?", [id])
  else
    halt 400, "Invalid item type"
  end

  status 200
end


# API Route to Fetch Indulgences for JavaScript Validation
get '/indulgences.json' do
  content_type :json
  indulgences = DB.execute("SELECT name, date FROM indulgences")
  indulgences.to_json
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

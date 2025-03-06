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
    calories INTEGER NOT NULL,
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

# Function to check if cardio is required today
def cardio_required_today?
  today = Date.today.to_s
  indulgence = DB.execute("SELECT * FROM indulgences WHERE date = ?", [today]).first
  !indulgence.nil?  # If there's an indulgence today, cardio is required
end

# Route to show the home page
get '/' do
  @workouts = DB.execute("SELECT * FROM workouts")
  @indulgences = DB.execute("SELECT * FROM indulgences")
  @cardio_required = cardio_required_today?

  # Convert workouts to a hash grouped by date for calendar display
  @workouts_by_date = @workouts.group_by { |w| w["date"] }
  @indulgences_by_date = @indulgences.group_by { |i| i["date"] }

  puts "Rendering index.erb"
  erb :index
end

# Route to add a new workout
post '/add_workout' do
  DB.execute("INSERT INTO workouts (name, date, duration) VALUES (?, ?, ?)",
             [params[:name], params[:date], params[:duration]])
  redirect '/'
end

post '/add_indulgence' do
  date = params[:date]
  name = params[:name].downcase  # Normalize name for alcohol detection
  day = Date.parse(date).strftime("%A").downcase  # Get day of the week

  puts "DEBUG: Trying to log #{name} on #{day}"  # Debugging output

  # Prevent alcohol logging on the day before Jiu-Jitsu (Sunday, Tuesday, Thursday)
  if ["sunday", "tuesday", "thursday"].include?(day) && name.include?("alcohol")
    puts "DEBUG: Blocked alcohol logging on #{day}"  # Debugging output
    return "🚫 Alcohol logging is not allowed the day before Jiu-Jitsu!", 400
  end

  DB.execute("INSERT INTO indulgences (name, calories, date) VALUES (?, ?, ?)",
             [params[:name], params[:calories], params[:date]])

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

# Explicit routes for CSS and JS
get '/css/style.css' do
  content_type 'text/css'
  send_file File.join(settings.public_folder, 'css', 'style.css')
end

get '/calendar.js' do
  content_type 'application/javascript'
  send_file File.join(settings.public_folder, 'calendar.js')
end

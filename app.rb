require 'sinatra'
require 'sqlite3'

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

# Route to show the home page
get '/' do
  @workouts = DB.execute("SELECT * FROM workouts")
  @indulgences = DB.execute("SELECT * FROM indulgences")

  # Convert workouts to a hash grouped by date for calendar display
  @workouts_by_date = @workouts.group_by { |w| w["date"] }
  @indulgences_by_date = @indulgences.group_by { |i| i["date"] }

  erb :index
end

# Route to add a new workout
post '/add_workout' do
  DB.execute("INSERT INTO workouts (name, date, duration) VALUES (?, ?, ?)",
             [params[:name], params[:date], params[:duration]])
  redirect '/'
end

# Route to add a new indulgence
post '/add_indulgence' do
  DB.execute("INSERT INTO indulgences (name, calories, date) VALUES (?, ?, ?) ",
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

# Route to serve JavaScript and CSS
get '/calendar.js' do
  content_type 'application/javascript'
  send_file 'public/calendar.js'
end

get '/style.css' do
  content_type 'text/css'
  send_file 'public/style.css'
end

__END__

@@ index
<!DOCTYPE html>
<html>
<head>
  <title>Fitness Tracker</title>
  <link rel="stylesheet" type="text/css" href="/style.css">
  <script src="/calendar.js" defer></script>
</head>
<body>
  <h1>Fitness Tracker</h1>

  <div id="calendar"></div>

  <form action="/add_workout" method="post">
    <h2>Add a Workout</h2>
    <input type="text" name="name" placeholder="Workout Name" required>
    <input type="date" name="date" required>
    <input type="number" name="duration" placeholder="Duration (minutes)" required>
    <button type="submit">Add Workout</button>
  </form>

  <form action="/add_indulgence" method="post">
    <h2>Add an Indulgence</h2>
    <input type="text" name="name" placeholder="Indulgence Name" required>
    <input type="number" name="calories" placeholder="Calories" required>
    <input type="date" name="date" required>
    <button type="submit">Add Indulgence</button>
  </form>

  <h2>Calendar</h2>
  <div class="calendar-grid">
    <% require 'date' %>
    <% start_date = Date.today.beginning_of_month %>
    <% end_date = Date.today.end_of_month %>
    
    <% (start_date..end_date).each do |date| %>
      <div class="calendar-day" data-date="<%= date.to_s %>">
        <strong><%= date.strftime("%b %d") %></strong>
        <ul>
          <% if @workouts_by_date[date.to_s] %>
            <% @workouts_by_date[date.to_s].each do |workout| %>
              <li class="workout" draggable="true" data-id="<%= workout["id"] %>">
                🏋️ <%= workout["name"] %> - <%= workout["duration"] %> min
              </li>
            <% end %>
          <% end %>
          <% if @indulgences_by_date[date.to_s] %>
            <% @indulgences_by_date[date.to_s].each do |indulgence| %>
              <li class="indulgence" draggable="true" data-id="<%= indulgence["id"] %>">
                🍔 <%= indulgence["name"] %> - <%= indulgence["calories"] %> cal
              </li>
            <% end %>
          <% end %>
        </ul>
      </div>
    <% end %>
  </div>
</body>
</html>

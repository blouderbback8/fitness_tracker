require 'sinatra/reloader' if development?
require 'sinatra'
require 'sqlite3'

# Create or open the SQLite database
DB = SQLite3::Database.new "fitness_tracker.db"

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

  # Calculate workout adjustments
  total_calories = @indulgences.map { |indulgence| indulgence[2] }.sum
  @extra_minutes = total_calories / 50  # Example: burn 50 calories per extra workout minute

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
  DB.execute("INSERT INTO indulgences (name, calories, date) VALUES (?, ?, ?)",
             [params[:name], params[:calories], params[:date]])
  redirect '/'
end

__END__

@@ index
<!DOCTYPE html>
<html>
<head>
  <title>Fitness Tracker</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f8f9fa;
      color: #333;
      margin: 0;
      padding: 0;
    }
    h1 {
      background-color: #007bff;
      color: white;
      padding: 10px 20px;
      text-align: center;
      margin: 0;
    }
    form {
      margin: 20px;
      text-align: center;
    }
    input, button {
      margin: 5px;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 4px;
      font-size: 16px;
    }
    button {
      background-color: #007bff;
      color: white;
      border: none;
      cursor: pointer;
    }
    button:hover {
      background-color: #0056b3;
    }
    h2 {
      margin: 20px;
      text-align: center;
    }
    ul {
      list-style-type: none;
      padding: 0;
      text-align: center;
    }
    li {
      margin: 10px 0;
      padding: 10px;
      background-color: #e9ecef;
      border-radius: 4px;
      display: inline-block;
      width: 50%;
    }
    strong {
      color: #007bff;
    }
  </style>
</head>
<body>
  <h1>Fitness Tracker</h1>

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

  <h2>Workouts</h2>
  <ul>
    <% @workouts.each do |workout| %>
      <li><strong><%= workout[1] %></strong> on <%= workout[2] %> for <%= workout[3] %> minutes</li>
    <% end %>
  </ul>

  <h2>Indulgences</h2>
  <ul>
    <% @indulgences.each do |indulgence| %>
      <li><strong><%= indulgence[1] %></strong>: <%= indulgence[2] %> calories on <%= indulgence[3] %></li>
    <% end %>
  </ul>

  <h2>Workout Adjustment</h2>
  <p>You need to add <strong><%= @extra_minutes %> minutes</strong> to your workouts this week to balance indulgences.</p>
</body>
</html>

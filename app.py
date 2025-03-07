import sqlite3

# Connect to the SQLite database
db = sqlite3.connect("fitness_tracker.db")
cursor = db.cursor()

# Ensure the database has the required tables
cursor.execute('''
CREATE TABLE IF NOT EXISTS indulgences (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    date TEXT NOT NULL
);
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS workouts (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    duration INTEGER NOT NULL,
    date TEXT NOT NULL
);
''')

# Fetch all workouts and indulgences
cursor.execute("SELECT * FROM workouts")
workouts = cursor.fetchall()

cursor.execute("SELECT * FROM indulgences")
indulgences = cursor.fetchall()

# Print out workouts and indulgences
print("Workouts:")
for workout in workouts:
    print(workout)

print("\nIndulgences:")
for indulgence in indulgences:
    print(indulgence)

# Close the database connection
cursor.close()
db.close()

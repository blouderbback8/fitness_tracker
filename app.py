import sqlite3

# Connect to the SQLite database
db = sqlite3.connect("fitness_tracker.db")
cursor = db.cursor()

# Ensure the database has the required tables
cursor.execute('''
CREATE TABLE IF NOT EXISTS indulgences (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    calories INTEGER NOT NULL,
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

# Calculate a basic workout adjustment based on indulgences
def calculate_adjustments(indulgences):
    total_calories = sum([indulgence[2] for indulgence in indulgences])
    extra_minutes = total_calories // 50  # Example: burn 50 calories per extra workout minute
    return extra_minutes

# Print out workouts and indulgences
print("Workouts:")
for workout in workouts:
    print(workout)

print("\nIndulgences:")
for indulgence in indulgences:
    print(indulgence)

# Calculate and print adjustments
extra_minutes = calculate_adjustments(indulgences)
print(f"\nYou need to add {extra_minutes} extra minutes to your workouts this week to balance indulgences.")

# Close the database connection
cursor.close()
db.close()

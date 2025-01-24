-- Step 1: Create the database
CREATE DATABASE fitness_tracker;

-- Step 2: Use the database
USE fitness_tracker;

-- Step 3: Create workout_schedule table
CREATE TABLE workout_schedule (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day VARCHAR(20),
    activity VARCHAR(255)
);

-- Step 4: Create indulgences table
CREATE TABLE indulgences (
    id INT AUTO_INCREMENT PRIMARY KEY,
    day VARCHAR(20),
    indulgence VARCHAR(255)
);

-- Step 5: Verify the tables
SHOW TABLES;

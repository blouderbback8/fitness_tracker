
# Fitness Tracker

A simple fitness tracking application built with **Sinatra**, **SQLite3**, and **Ruby**.

## Features
- Log and track **workouts** (name, date, duration).
- Log and track **indulgences** (food, calories, date).
- Automatically calculates how much workout time is needed to balance indulgences.
- Uses **SQLite3** for local data storage.

## Prerequisites
Before running the app, make sure you have the following installed:
- [Ruby](https://www.ruby-lang.org/en/downloads/) (version 3.x recommended)
- [Git](https://git-scm.com/downloads)
- [SQLite3](https://www.sqlite.org/download.html)
- [Bundler](https://bundler.io/) (if not installed, run `gem install bundler`)

## Installation
1. **Clone the Repository**
   ```
   git clone https://github.com/blouderbback8/fitness_tracker.git
   cd fitness_tracker
   ```
2. **Install Dependencies**
   ```
   gem install sinatra sqlite3 rackup puma
   ```

## Running the App
1. **Navigate to the project folder in Git Bash**
   ```
   cd /c/xampp/htdocs/fitness_tracker
   ```
2. **Start the Sinatra Server**
   ```
   ruby app.rb
   ```
3. **Access the App**  
   Open a browser and go to: **http://127.0.0.1:4567/**

## Troubleshooting
- If you see **missing gem errors**, install them using:
  ```
  gem install <gem_name>
  ```
- If you get **SQLite3 errors**, ensure SQLite3 is installed and accessible.

## Future Improvements
- Improve UI design
- Add authentication for multiple users
- Deploy to a web hosting service

## License
This project is licensed under the MIT License.

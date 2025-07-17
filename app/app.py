from flask import Flask, render_template, jsonify, request, redirect, url_for
from datetime import datetime, timedelta
import sqlite3
import os

app = Flask(__name__)

# Database setup
DB_PATH = os.path.join(os.path.dirname(__file__), 'f1_app.db')

def init_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute('''
    CREATE TABLE IF NOT EXISTS user_predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        favorite_team TEXT NOT NULL,
        favorite_driver TEXT NOT NULL,
        race_winner TEXT NOT NULL,
        comments TEXT,
        submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''')
    conn.commit()
    conn.close()

# Initialize database on startup
init_db()

# Helper function to get team CSS class
def get_team_class(team_name):
    team_classes = {
        'Ferrari': 'ferrari',
        'Mercedes': 'mercedes',
        'Red Bull Racing': 'redbull',
        'McLaren': 'mclaren',
        'Aston Martin': 'aston',
        'Alpine': 'alpine',
        'Williams': 'williams',
        'RB': 'rb',
        'Haas': 'haas',
        'Kick Sauber': 'sauber'
    }
    return team_classes.get(team_name, '')

# Sample data for the application
f1_data = {
    'drivers': [
        {'id': 1, 'name': 'Max Verstappen', 'team': 'Red Bull Racing', 'points': 170, 'wins': 5, 'podiums': 7, 'code': 'VER', 'team_color': 'redbull'},
        {'id': 2, 'name': 'Charles Leclerc', 'team': 'Ferrari', 'points': 138, 'wins': 2, 'podiums': 5, 'code': 'LEC', 'team_color': 'ferrari'},
        {'id': 3, 'name': 'Lando Norris', 'team': 'McLaren', 'points': 115, 'wins': 1, 'podiums': 4, 'code': 'NOR', 'team_color': 'mclaren'},
        {'id': 4, 'name': 'Lewis Hamilton', 'team': 'Mercedes', 'points': 96, 'wins': 0, 'podiums': 3, 'code': 'HAM', 'team_color': 'mercedes'},
        {'id': 5, 'name': 'Carlos Sainz', 'team': 'Ferrari', 'points': 92, 'wins': 0, 'podiums': 3, 'code': 'SAI', 'team_color': 'ferrari'},
        {'id': 6, 'name': 'George Russell', 'team': 'Mercedes', 'points': 85, 'wins': 0, 'podiums': 2, 'code': 'RUS', 'team_color': 'mercedes'},
        {'id': 7, 'name': 'Sergio Perez', 'team': 'Red Bull Racing', 'points': 82, 'wins': 0, 'podiums': 1, 'code': 'PER', 'team_color': 'redbull'},
        {'id': 8, 'name': 'Fernando Alonso', 'team': 'Aston Martin', 'points': 65, 'wins': 0, 'podiums': 2, 'code': 'ALO', 'team_color': 'aston'},
    ],
    'teams': [
        {'id': 1, 'name': 'Red Bull Racing', 'points': 285, 'wins': 5, 'color': 'redbull'},
        {'id': 2, 'name': 'Ferrari', 'points': 230, 'wins': 2, 'color': 'ferrari'},
        {'id': 3, 'name': 'McLaren', 'points': 196, 'wins': 1, 'color': 'mclaren'},
        {'id': 4, 'name': 'Mercedes', 'points': 187, 'wins': 0, 'color': 'mercedes'},
        {'id': 5, 'name': 'Aston Martin', 'points': 86, 'wins': 0, 'color': 'aston'},
        {'id': 6, 'name': 'Alpine', 'points': 35, 'wins': 0, 'color': 'alpine'},
        {'id': 7, 'name': 'Williams', 'points': 21, 'wins': 0, 'color': 'williams'},
        {'id': 8, 'name': 'RB', 'points': 17, 'wins': 0, 'color': 'rb'},
    ],
    'races': [
        {'id': 1, 'name': 'Bahrain Grand Prix', 'date': '2025-03-02', 'circuit': 'Bahrain International Circuit', 'location': 'Sakhir, Bahrain', 'winner': 'Max Verstappen', 'status': 'completed'},
        {'id': 2, 'name': 'Saudi Arabian Grand Prix', 'date': '2025-03-09', 'circuit': 'Jeddah Corniche Circuit', 'location': 'Jeddah, Saudi Arabia', 'winner': 'Max Verstappen', 'status': 'completed'},
        {'id': 3, 'name': 'Australian Grand Prix', 'date': '2025-03-23', 'circuit': 'Albert Park Circuit', 'location': 'Melbourne, Australia', 'winner': 'Charles Leclerc', 'status': 'completed'},
        {'id': 4, 'name': 'Japanese Grand Prix', 'date': '2025-04-06', 'circuit': 'Suzuka International Racing Course', 'location': 'Suzuka, Japan', 'winner': 'Max Verstappen', 'status': 'completed'},
        {'id': 5, 'name': 'Chinese Grand Prix', 'date': '2025-04-20', 'circuit': 'Shanghai International Circuit', 'location': 'Shanghai, China', 'winner': 'Lando Norris', 'status': 'completed'},
        {'id': 6, 'name': 'Miami Grand Prix', 'date': '2025-05-04', 'circuit': 'Miami International Autodrome', 'location': 'Miami, USA', 'winner': 'Max Verstappen', 'status': 'completed'},
        {'id': 7, 'name': 'Emilia Romagna Grand Prix', 'date': '2025-05-18', 'circuit': 'Autodromo Enzo e Dino Ferrari', 'location': 'Imola, Italy', 'winner': 'Max Verstappen', 'status': 'completed'},
        {'id': 8, 'name': 'Monaco Grand Prix', 'date': '2025-05-25', 'circuit': 'Circuit de Monaco', 'location': 'Monte Carlo, Monaco', 'winner': 'Charles Leclerc', 'status': 'completed'},
        {'id': 9, 'name': 'Spanish Grand Prix', 'date': '2025-07-29', 'circuit': 'Circuit de Barcelona-Catalunya', 'location': 'Barcelona, Spain', 'winner': None, 'status': 'upcoming'},
        {'id': 10, 'name': 'Austrian Grand Prix', 'date': '2025-08-05', 'circuit': 'Red Bull Ring', 'location': 'Spielberg, Austria', 'winner': None, 'status': 'upcoming'},
    ]
}

# Helper function to get the next race
def get_next_race():
    today = datetime.now().date()
    upcoming_races = [race for race in f1_data['races'] if race['status'] == 'upcoming']
    if upcoming_races:
        next_race = upcoming_races[0]
        race_date = datetime.strptime(next_race['date'], '%Y-%m-%d').date()
        days_until = (race_date - today).days
        return {
            'race': next_race,
            'days_until': days_until
        }
    return None

# Helper function to get recent user predictions
def get_recent_predictions(limit=3):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute('''
    SELECT * FROM user_predictions 
    ORDER BY submission_date DESC 
    LIMIT ?
    ''', (limit,))
    
    predictions = []
    for row in cursor.fetchall():
        # Format the date nicely
        submission_date = datetime.strptime(row['submission_date'], '%Y-%m-%d %H:%M:%S')
        formatted_date = submission_date.strftime('%B %d, %Y')
        
        # Get first name and last initial
        name_parts = row['name'].split()
        if len(name_parts) > 1:
            display_name = f"{name_parts[0]} {name_parts[-1][0]}."
        else:
            display_name = name_parts[0]
            
        predictions.append({
            'name': display_name,
            'date': formatted_date,
            'favorite_team': row['favorite_team'],
            'favorite_driver': row['favorite_driver'],
            'race_winner': row['race_winner'],
            'comments': row['comments'],
            'team_class': get_team_class(row['favorite_team'])
        })
    
    conn.close()
    return predictions

@app.route('/')
def home():
    next_race_info = get_next_race()
    top_drivers = sorted(f1_data['drivers'], key=lambda x: x['points'], reverse=True)[:5]
    top_teams = sorted(f1_data['teams'], key=lambda x: x['points'], reverse=True)[:5]
    user_predictions = get_recent_predictions()
    
    return render_template('index.html', 
                          next_race=next_race_info,
                          top_drivers=top_drivers,
                          top_teams=top_teams,
                          user_predictions=user_predictions)

@app.route('/submit_prediction', methods=['POST'])
def submit_prediction():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        favorite_team = request.form.get('favorite_team')
        favorite_driver = request.form.get('favorite_driver')
        race_winner = request.form.get('race_winner')
        comments = request.form.get('comments')
        
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute('''
        INSERT INTO user_predictions 
        (name, email, favorite_team, favorite_driver, race_winner, comments)
        VALUES (?, ?, ?, ?, ?, ?)
        ''', (name, email, favorite_team, favorite_driver, race_winner, comments))
        
        conn.commit()
        conn.close()
        
        return redirect(url_for('home'))

@app.route('/teams')
def teams():
    teams_data = sorted(f1_data['teams'], key=lambda x: x['points'], reverse=True)
    return render_template('teams.html', teams=teams_data)

@app.route('/teams/<int:team_id>')
def team_detail(team_id):
    team = next((t for t in f1_data['teams'] if t['id'] == team_id), None)
    if team:
        team_drivers = [d for d in f1_data['drivers'] if d['team'] == team['name']]
        return render_template('team_detail.html', team=team, drivers=team_drivers)
    return "Team not found", 404

@app.route('/drivers')
def drivers():
    drivers_data = sorted(f1_data['drivers'], key=lambda x: x['points'], reverse=True)
    return render_template('drivers.html', drivers=drivers_data)

@app.route('/drivers/<int:driver_id>')
def driver_detail(driver_id):
    driver = next((d for d in f1_data['drivers'] if d['id'] == driver_id), None)
    if driver:
        return render_template('driver_detail.html', driver=driver)
    return "Driver not found", 404

@app.route('/races')
def races():
    past_races = [race for race in f1_data['races'] if race['status'] == 'completed']
    upcoming_races = [race for race in f1_data['races'] if race['status'] == 'upcoming']
    return render_template('races.html', past_races=past_races, upcoming_races=upcoming_races)

@app.route('/races/<int:race_id>')
def race_detail(race_id):
    race = next((r for r in f1_data['races'] if r['id'] == race_id), None)
    if race:
        return render_template('race_detail.html', race=race)
    return "Race not found", 404

@app.route('/standings')
def standings():
    drivers_standings = sorted(f1_data['drivers'], key=lambda x: x['points'], reverse=True)
    teams_standings = sorted(f1_data['teams'], key=lambda x: x['points'], reverse=True)
    return render_template('standings.html', drivers=drivers_standings, teams=teams_standings)

@app.route('/api/next-race')
def api_next_race():
    next_race_info = get_next_race()
    return jsonify(next_race_info)

@app.route('/api/standings/drivers')
def api_drivers_standings():
    drivers = sorted(f1_data['drivers'], key=lambda x: x['points'], reverse=True)
    return jsonify(drivers)

@app.route('/api/standings/teams')
def api_teams_standings():
    teams = sorted(f1_data['teams'], key=lambda x: x['points'], reverse=True)
    return jsonify(teams)

if __name__ == '__main__':
    app.run(debug=True)

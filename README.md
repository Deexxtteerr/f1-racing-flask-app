# F1 Racing Flask Application

A Flask-based web application for Formula 1 racing information and fan engagement.

## Features

- View race schedules and results
- Driver standings and statistics
- Team rankings and information
- Fan predictions and comments
- Real-time race updates

## Accessing the Application

### Local Development Access
```
Root URL: http://localhost/f1-racing/
```

### Cloud Deployment Access
```
Root URL: http://54.85.253.7/f1-racing/
```

Note: Cloud deployment URL will change if EC2 instance is stopped and restarted.

## Local Development Setup

### Prerequisites

- Docker and Docker Compose
- Git

### Running Locally with Docker

1. Clone the repository:
```bash
git clone https://github.com/Deexxtteerr/f1-racing-flask-app.git
cd f1-racing-flask-app
```

2. Start the application:
```bash
docker-compose up -d
```

3. Access the application:
```
http://localhost/f1-racing/
```

### Managing the Application

- **Start the application**:
  ```bash
  docker-compose up -d
  ```

- **Stop the application**:
  ```bash
  docker-compose down
  ```

- **View logs**:
  ```bash
  docker-compose logs -f
  ```

- **Restart the application**:
  ```bash
  docker-compose restart
  ```

### Project Structure

```
f1-racing-flask-app/
├── app/
│   ├── static/
│   │   ├── images/
│   │   └── style.css
│   ├── templates/
│   │   ├── index.html
│   │   ├── drivers.html
│   │   ├── teams.html
│   │   ├── races.html
│   │   └── standings.html
│   └── app.py
├── nginx/
│   └── f1-racing.conf
├── supervisor/
│   └── supervisord.conf
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
└── start.sh
```

## URL Structure

### Main URLs
- `/f1-racing/` - Home page
- `/f1-racing/drivers` - Drivers information
- `/f1-racing/teams` - Teams information
- `/f1-racing/races` - Race schedules
- `/f1-racing/standings` - Current standings

### API Endpoints
- `/f1-racing/api/next-race` - Get next race information
- `/f1-racing/api/standings/drivers` - Get driver standings
- `/f1-racing/api/standings/teams` - Get team standings

## Deployment

The application can be deployed in two ways:

1. **Local Deployment (Docker)**:
   - Uses Docker and Docker Compose
   - Runs on localhost
   - Perfect for development and testing
   - Access via `http://localhost/f1-racing/`

2. **Cloud Deployment (AWS)**:
   - Uses Jenkins for CI/CD
   - Deploys to AWS EC2
   - Suitable for production use
   - Access via `http://[EC2-IP]/f1-racing/`

## Technologies Used

- **Backend**: Python Flask
- **Frontend**: HTML, CSS, JavaScript
- **Database**: SQLite
- **Server**: Nginx
- **Process Management**: Supervisor
- **Containerization**: Docker
- **CI/CD**: Jenkins

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

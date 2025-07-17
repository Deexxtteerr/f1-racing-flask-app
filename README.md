# F1 Racing Flask Application

## Setup

1. (Optional) Create and activate a virtual environment:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run the Flask app:
   ```bash
   cd app
   flask run
   ```
   or
   ```bash
   cd app
   python app.py
   ```

## App Structure
- `app/app.py`: Main Flask app
- `app/templates/`: HTML templates
- `app/static/`: CSS, JavaScript, and image files
- `app/f1_app.db`: SQLite database for user predictions
- `requirements.txt`: Python dependencies

## Features
- View F1 race calendar, teams, drivers, and standings
- Interactive user prediction system
- Dynamic content based on user submissions
- Responsive design for all devices

Visit `http://127.0.0.1:5000/` in your browser to view the app.

## Docker Support

You can run the application using Docker:

```bash
# Build and run with Docker
docker build -t python-flask-app .
docker run -p 5000:5000 python-flask-app

# Or use docker-compose
docker-compose up
```

## CI/CD Pipeline with Jenkins

This project includes a Jenkinsfile that defines a complete CI/CD pipeline:

1. Checkout code from repository
2. Set up Python environment and install dependencies
3. Run tests
4. Build Docker image
5. Deploy to application server
6. Verify deployment

## Infrastructure as Code with Terraform

The `terraform` directory contains configuration to provision:

1. A VPC with public subnet
2. Security groups for Jenkins and application servers
3. EC2 instances for Jenkins and the Python application
4. All necessary networking components

### Deploying Infrastructure

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Create SSH key for EC2 instances
ssh-keygen -t rsa -b 2048 -f ~/.ssh/python-app-key -N ""

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# When finished, destroy resources
terraform destroy
```

After deployment, Terraform will output:
- IP addresses and DNS names for both servers
- URLs to access Jenkins and the Python application
- SSH commands to connect to the servers

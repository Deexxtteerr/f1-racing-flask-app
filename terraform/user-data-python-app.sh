#!/bin/bash

# Update package lists
apt-get update -y

# Install necessary packages
apt-get install -y apt-transport-https ca-certificates curl software-properties-common python3-pip python3-venv

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
systemctl start docker
systemctl enable docker

# Create deployment directory
mkdir -p /opt/python-deployment
chmod 755 /opt/python-deployment

# Install Python dependencies
pip3 install flask gunicorn

# Create a simple test file to verify the server is running
cat > /opt/python-deployment/test.py << 'EOL'
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Python Flask server is running!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
EOL

# Create a systemd service file for the test app
cat > /etc/systemd/system/flask-test.service << 'EOL'
[Unit]
Description=Flask Test App
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/opt/python-deployment
ExecStart=/usr/bin/python3 /opt/python-deployment/test.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Set proper ownership
chown -R ubuntu:ubuntu /opt/python-deployment

# Enable and start the service
systemctl daemon-reload
systemctl enable flask-test
systemctl start flask-test

echo "Python application server setup complete"

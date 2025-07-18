#!/bin/bash

# Update package lists
apt-get update -y

# Install necessary packages
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker service
systemctl start docker
systemctl enable docker

# Install Java (required for Jenkins)
apt-get install -y openjdk-11-jdk

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update -y
apt-get install -y jenkins

# Start Jenkins service
systemctl start jenkins
systemctl enable jenkins

# Add jenkins user to docker group to allow Jenkins to use Docker
usermod -aG docker jenkins

# Restart Jenkins to apply changes
systemctl restart jenkins

# Create deployment directory
mkdir -p /opt/jenkins-deployment
chown -R jenkins:jenkins /opt/jenkins-deployment

# Print initial admin password for Jenkins setup
echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword

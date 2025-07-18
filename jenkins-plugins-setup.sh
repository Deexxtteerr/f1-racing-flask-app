#!/bin/bash

# List of required plugins for webhook integration
JENKINS_PLUGINS=(
  "github-integration"
  "generic-webhook-trigger"
  "pipeline-github"
  "git"
  "github"
)

# Install Jenkins CLI if not already installed
if [ ! -f jenkins-cli.jar ]; then
  echo "Downloading Jenkins CLI..."
  wget http://localhost:8080/jnlpJars/jenkins-cli.jar
fi

# Get Jenkins admin token from file or environment variable
# Replace with your actual token or method to retrieve it
JENKINS_TOKEN="your_jenkins_token_here"

# Install each plugin
for plugin in "${JENKINS_PLUGINS[@]}"; do
  echo "Installing plugin: $plugin"
  java -jar jenkins-cli.jar -auth admin:$JENKINS_TOKEN -s http://localhost:8080 install-plugin $plugin
done

echo "Restarting Jenkins to apply changes..."
java -jar jenkins-cli.jar -auth admin:$JENKINS_TOKEN -s http://localhost:8080 safe-restart

echo "Jenkins plugins installation complete. Jenkins is restarting."

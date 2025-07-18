#!/bin/bash

# This script simulates a GitHub webhook payload to test your Jenkins webhook setup locally
# It requires curl to be installed

# Configuration - replace these values with your own
JENKINS_URL="http://localhost:8080"
WEBHOOK_PATH="/github-webhook/"
GITHUB_USER="YOUR_GITHUB_USERNAME"
GITHUB_REPO="python-flask-app"
BRANCH="main"

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it first."
    exit 1
fi

# Create a temporary file for the payload
PAYLOAD_FILE=$(mktemp)

# Generate a sample GitHub push event payload
cat > $PAYLOAD_FILE << EOF
{
  "ref": "refs/heads/$BRANCH",
  "repository": {
    "name": "$GITHUB_REPO",
    "full_name": "$GITHUB_USER/$GITHUB_REPO",
    "owner": {
      "name": "$GITHUB_USER",
      "email": "user@example.com"
    },
    "html_url": "https://github.com/$GITHUB_USER/$GITHUB_REPO"
  },
  "pusher": {
    "name": "$GITHUB_USER",
    "email": "user@example.com"
  },
  "sender": {
    "login": "$GITHUB_USER"
  },
  "after": "1234567890abcdef1234567890abcdef12345678",
  "commits": [
    {
      "id": "1234567890abcdef1234567890abcdef12345678",
      "message": "Test commit for webhook",
      "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "author": {
        "name": "$GITHUB_USER",
        "email": "user@example.com"
      }
    }
  ]
}
EOF

# Send the webhook payload to Jenkins
echo "Sending test webhook payload to $JENKINS_URL$WEBHOOK_PATH"
curl -X POST \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "X-GitHub-Delivery: $(uuidgen)" \
  -d @$PAYLOAD_FILE \
  "$JENKINS_URL$WEBHOOK_PATH"

# Clean up
rm $PAYLOAD_FILE

echo -e "\n\nWebhook test complete. Check your Jenkins server for triggered jobs."
echo "If no job was triggered, check the Jenkins logs for errors."

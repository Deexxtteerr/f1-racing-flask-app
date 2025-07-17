#!/bin/bash

# This script sets up a GitHub webhook for your repository
# Prerequisites: GitHub CLI (gh) installed and authenticated

# Configuration - replace these values with your own
REPO_NAME="YOUR_GITHUB_USERNAME/python-flask-app"
JENKINS_URL="http://your-jenkins-server:8080"
WEBHOOK_SECRET="your-webhook-secret"  # Optional but recommended for security

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) is not installed. Please install it first."
    echo "Visit: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated with GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "You are not authenticated with GitHub CLI. Please run 'gh auth login' first."
    exit 1
fi

# Create the webhook
echo "Creating webhook for repository: $REPO_NAME"
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /repos/$REPO_NAME/hooks \
  -f url="$JENKINS_URL/github-webhook/" \
  -f content_type="application/json" \
  -f secret="$WEBHOOK_SECRET" \
  -f events[]="push" \
  -f events[]="pull_request" \
  -f events[]="create" \
  -f active=true

# Check if webhook was created successfully
if [ $? -eq 0 ]; then
    echo "Webhook created successfully!"
    echo "Jenkins will now be automatically triggered on repository events."
else
    echo "Failed to create webhook. Please check your configuration and try again."
    exit 1
fi

echo ""
echo "Next steps:"
echo "1. Make sure your Jenkins server is accessible from the internet"
echo "2. Configure your Jenkins job to use the Jenkinsfile in your repository"
echo "3. If you set a webhook secret, configure it in your Jenkins GitHub plugin settings"
echo ""
echo "To test the webhook, make a small change to your repository and push it."

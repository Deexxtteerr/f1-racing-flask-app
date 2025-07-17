# Automatic CI/CD Pipeline with GitHub Webhooks

This guide explains how to set up automatic triggering of your Jenkins CI/CD pipeline using GitHub webhooks. When properly configured, any push to your GitHub repository will automatically trigger your Jenkins pipeline to build, test, and deploy your Python Flask application.

## Overview of the Process

1. Set up Jenkins with necessary plugins
2. Configure GitHub repository with webhook
3. Create Jenkins multibranch pipeline job
4. Test the webhook integration

## Prerequisites

- A GitHub repository containing your Python Flask application
- A Jenkins server accessible from the internet (with a public IP or domain)
- Administrative access to both GitHub and Jenkins

## Detailed Setup Instructions

### 1. Jenkins Server Configuration

#### Install Required Plugins

In Jenkins, go to "Manage Jenkins" > "Manage Plugins" > "Available" and install:

- GitHub Integration
- GitHub Branch Source
- Pipeline: GitHub
- SSH Agent
- Git Integration

You can use the provided script to install these plugins automatically:

```bash
chmod +x jenkins-plugins-setup.sh
./jenkins-plugins-setup.sh
```

#### Configure GitHub Server in Jenkins

1. Go to "Manage Jenkins" > "Configure System"
2. Scroll to "GitHub" section
3. Add GitHub Server:
   - Name: GitHub
   - API URL: https://api.github.com
   - Credentials: Add > Jenkins > Select "GitHub Access Token"
   - Test connection to verify
   - Check "Manage hooks"
4. Save the configuration

### 2. Create GitHub Personal Access Token

1. In GitHub, go to Settings > Developer settings > Personal access tokens
2. Generate new token (classic)
3. Name it "Jenkins Integration"
4. Select scopes:
   - `repo` (all)
   - `admin:repo_hook`
5. Generate and copy the token

### 3. Add GitHub Credentials to Jenkins

1. In Jenkins, go to "Manage Jenkins" > "Manage Credentials"
2. Select "Jenkins" store and "Global credentials"
3. Click "Add Credentials"
4. Fill in:
   - Kind: Username with password
   - Username: Your GitHub username
   - Password: The personal access token you generated
   - ID: github-credentials
   - Description: GitHub Access Token
5. Click "OK"

### 4. Create Multibranch Pipeline in Jenkins

You can create the pipeline manually or use the provided script:

```bash
# Edit the script to add your credentials
nano configure-jenkins-webhook.sh

# Make it executable and run
chmod +x configure-jenkins-webhook.sh
./configure-jenkins-webhook.sh
```

For manual setup:

1. In Jenkins, click "New Item"
2. Enter name (e.g., "python-flask-app")
3. Select "Multibranch Pipeline"
4. Configure:
   - Display Name: Python Flask App
   - Branch Sources: Add source > GitHub
   - Credentials: Select your GitHub credentials
   - Repository HTTPS URL: Your GitHub repository URL
   - Behaviors: 
     - Discover branches
     - Discover pull requests from origin
   - Build Configuration:
     - Mode: by Jenkinsfile
     - Script Path: Jenkinsfile
5. Save

### 5. Set Up GitHub Webhook (if not automatic)

If Jenkins doesn't automatically create the webhook:

```bash
# Edit with your details
nano setup-github-webhook.sh

# Make executable and run
chmod +x setup-github-webhook.sh
./setup-github-webhook.sh
```

For manual setup in GitHub:

1. Go to your repository > Settings > Webhooks
2. Click "Add webhook"
3. Configure:
   - Payload URL: `http://your-jenkins-server:8080/github-webhook/`
   - Content type: application/json
   - Events: Just the push event (or select individual events)
4. Click "Add webhook"

### 6. Test the Integration

1. Make a change to your repository
2. Commit and push the change
3. Check Jenkins to see if a build is automatically triggered
4. Verify the build completes successfully

## Troubleshooting

### Webhook Not Triggering

1. Check GitHub webhook delivery history (Repository > Settings > Webhooks > click webhook > Recent Deliveries)
2. Ensure Jenkins is accessible from the internet
3. Verify correct webhook URL
4. Check Jenkins logs for errors

### Authentication Issues

1. Verify GitHub credentials in Jenkins
2. Ensure the personal access token has correct permissions
3. Check if token has expired and regenerate if needed

### Build Failures

1. Check Jenkins build logs for errors
2. Verify Jenkinsfile syntax
3. Ensure all required credentials are configured in Jenkins

## Security Considerations

- Use HTTPS for your Jenkins server
- Consider adding a webhook secret
- Limit GitHub token permissions to only what's needed
- Regularly rotate GitHub tokens

## Additional Resources

- [Jenkins GitHub Integration Documentation](https://plugins.jenkins.io/github-integration/)
- [GitHub Webhooks Documentation](https://docs.github.com/en/developers/webhooks-and-events/webhooks/about-webhooks)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)

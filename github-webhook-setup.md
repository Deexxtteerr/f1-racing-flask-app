# Setting Up GitHub Webhooks for Jenkins Integration

This guide explains how to set up GitHub webhooks to automatically trigger your Jenkins pipeline when changes are pushed to your repository.

## Prerequisites

1. A GitHub repository for your Python Flask application
2. A Jenkins server accessible from the internet (with a public IP or domain)
3. Admin access to both GitHub and Jenkins

## Step 1: Create a GitHub Personal Access Token

1. Log in to GitHub
2. Go to Settings > Developer settings > Personal access tokens > Tokens (classic)
3. Click "Generate new token" and select "Generate new token (classic)"
4. Give it a descriptive name like "Jenkins Integration"
5. Select the following scopes:
   - `repo` (all)
   - `admin:repo_hook`
6. Click "Generate token"
7. **IMPORTANT**: Copy the generated token and save it securely. You won't be able to see it again!

## Step 2: Add GitHub Credentials to Jenkins

1. Log in to Jenkins
2. Go to "Manage Jenkins" > "Manage Credentials"
3. Click on the domain (usually "global")
4. Click "Add Credentials"
5. Fill in the form:
   - Kind: "Username with password"
   - Scope: "Global"
   - Username: Your GitHub username
   - Password: The personal access token you generated
   - ID: "github-credentials" (this ID is referenced in the Jenkins job configuration)
   - Description: "GitHub Access Token"
6. Click "OK"

## Step 3: Configure Jenkins for Webhook Reception

1. Go to "Manage Jenkins" > "Configure System"
2. Scroll down to the "GitHub" section
3. Click "Add GitHub Server"
4. Set a name like "GitHub"
5. For API URL, use `https://api.github.com`
6. For Credentials, select the GitHub credentials you just created
7. Test the connection to make sure it works
8. Check "Manage hooks"
9. Save the configuration

## Step 4: Create a Multibranch Pipeline in Jenkins

1. In Jenkins, click "New Item"
2. Enter a name for your project (e.g., "python-flask-app")
3. Select "Multibranch Pipeline" and click "OK"
4. In the configuration page:
   - Display Name: "Python Flask App"
   - Description: "Python Flask Application CI/CD Pipeline"
   - Branch Sources: Add source > GitHub
   - Credentials: Select your GitHub credentials
   - Repository HTTPS URL: Your GitHub repository URL
   - Behaviors: 
     - Discover branches
     - Discover pull requests from origin
     - Discover pull requests from forks
   - Build Configuration:
     - Mode: by Jenkinsfile
     - Script Path: Jenkinsfile
5. Save the configuration

## Step 5: Set Up the GitHub Webhook Manually (Alternative to Jenkins Auto-Registration)

If Jenkins doesn't automatically register the webhook (which it should if "Manage hooks" is enabled):

1. In GitHub, go to your repository
2. Click "Settings" > "Webhooks" > "Add webhook"
3. Fill in the form:
   - Payload URL: `https://your-jenkins-server/github-webhook/`
   - Content type: `application/json`
   - Secret: Leave blank (or set a secret and configure it in Jenkins)
   - Which events would you like to trigger this webhook?
     - Select "Just the push event" for simple setups
     - Or "Let me select individual events" and choose:
       - Push
       - Pull requests
       - Create (for new branches/tags)
4. Ensure "Active" is checked
5. Click "Add webhook"

## Step 6: Test the Webhook

1. Make a small change to your repository
2. Commit and push the change
3. Go to Jenkins and verify that a new build is automatically triggered
4. Check the build logs to ensure everything is working correctly

## Troubleshooting

If webhooks aren't working:

1. Check that your Jenkins server is accessible from the internet
2. Verify the webhook URL is correct
3. Look at the webhook delivery history in GitHub (Settings > Webhooks > click on your webhook > Recent Deliveries)
4. Check Jenkins logs for any errors
5. Ensure your GitHub credentials in Jenkins have the correct permissions

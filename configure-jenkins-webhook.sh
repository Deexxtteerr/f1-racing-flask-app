#!/bin/bash

# This script configures Jenkins to receive webhooks from GitHub
# Prerequisites: Jenkins CLI jar file and proper credentials

# Configuration - replace these values with your own
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_API_TOKEN="your-jenkins-api-token"  # Get this from Jenkins user configuration
JOB_NAME="python-flask-app"
GITHUB_USER="YOUR_GITHUB_USERNAME"
GITHUB_REPO="python-flask-app"
GITHUB_TOKEN="your-github-personal-access-token"

# Check if Jenkins CLI jar exists, download if not
if [ ! -f jenkins-cli.jar ]; then
    echo "Downloading Jenkins CLI..."
    curl -O ${JENKINS_URL}/jnlpJars/jenkins-cli.jar
fi

# Function to run Jenkins CLI commands
jenkins_cli() {
    java -jar jenkins-cli.jar -s ${JENKINS_URL} -auth ${JENKINS_USER}:${JENKINS_API_TOKEN} "$@"
}

# Install required plugins if not already installed
echo "Checking and installing required plugins..."
REQUIRED_PLUGINS=("github" "github-branch-source" "workflow-multibranch" "git" "pipeline-github" "ssh-agent")

for plugin in "${REQUIRED_PLUGINS[@]}"; do
    if ! jenkins_cli list-plugins | grep -q "${plugin}"; then
        echo "Installing plugin: ${plugin}"
        jenkins_cli install-plugin "${plugin}"
        RESTART_NEEDED=true
    fi
done

# Restart Jenkins if plugins were installed
if [ "$RESTART_NEEDED" = true ]; then
    echo "Restarting Jenkins to apply plugin changes..."
    jenkins_cli safe-restart
    echo "Waiting for Jenkins to restart..."
    sleep 30
fi

# Create credentials for GitHub
echo "Creating GitHub credentials in Jenkins..."
cat > github-credentials.xml << EOF
<com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>github-credentials</id>
  <description>GitHub Access Token</description>
  <username>${GITHUB_USER}</username>
  <password>${GITHUB_TOKEN}</password>
</com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl>
EOF

jenkins_cli create-credentials-by-xml system::system::jenkins _ < github-credentials.xml
rm github-credentials.xml

# Create the multibranch pipeline job
echo "Creating multibranch pipeline job for Python Flask app..."
cat > job-config.xml << EOF
<?xml version='1.1' encoding='UTF-8'?>
<org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject>
  <actions/>
  <description>Python Flask Application CI/CD Pipeline</description>
  <displayName>Python Flask App</displayName>
  <properties/>
  <folderViews class="jenkins.branch.MultiBranchProjectViewHolder">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </folderViews>
  <healthMetrics/>
  <icon class="jenkins.branch.MetadataActionFolderIcon">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </icon>
  <orphanedItemStrategy class="com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy">
    <pruneDeadBranches>true</pruneDeadBranches>
    <daysToKeep>-1</daysToKeep>
    <numToKeep>-1</numToKeep>
    <abortBuilds>false</abortBuilds>
  </orphanedItemStrategy>
  <triggers>
    <com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger>
      <spec>H H/4 * * *</spec>
      <interval>86400000</interval>
    </com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger>
  </triggers>
  <disabled>false</disabled>
  <sources class="jenkins.branch.MultiBranchProject\$BranchSourceList">
    <data>
      <jenkins.branch.BranchSource>
        <source class="org.jenkinsci.plugins.github_branch_source.GitHubSCMSource">
          <id>python-flask-app</id>
          <apiUri>https://api.github.com</apiUri>
          <credentialsId>github-credentials</credentialsId>
          <repoOwner>${GITHUB_USER}</repoOwner>
          <repository>${GITHUB_REPO}</repository>
          <traits>
            <org.jenkinsci.plugins.github__branch__source.BranchDiscoveryTrait>
              <strategyId>1</strategyId>
            </org.jenkinsci.plugins.github__branch__source.BranchDiscoveryTrait>
            <org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait>
              <strategyId>1</strategyId>
            </org.jenkinsci.plugins.github__branch__source.OriginPullRequestDiscoveryTrait>
            <org.jenkinsci.plugins.github__branch__source.WebhookRegistrationTrait>
              <mode>ITEM</mode>
            </org.jenkinsci.plugins.github__branch__source.WebhookRegistrationTrait>
          </traits>
        </source>
        <strategy class="jenkins.branch.DefaultBranchPropertyStrategy">
          <properties class="empty-list"/>
        </strategy>
      </jenkins.branch.BranchSource>
    </data>
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </sources>
  <factory class="org.jenkinsci.plugins.workflow.multibranch.WorkflowBranchProjectFactory">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
    <scriptPath>Jenkinsfile</scriptPath>
  </factory>
</org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject>
EOF

# Create or update the job
if jenkins_cli list-jobs | grep -q "${JOB_NAME}"; then
    echo "Updating existing job: ${JOB_NAME}"
    jenkins_cli update-job "${JOB_NAME}" < job-config.xml
else
    echo "Creating new job: ${JOB_NAME}"
    jenkins_cli create-job "${JOB_NAME}" < job-config.xml
fi

rm job-config.xml

echo "Configuration complete!"
echo ""
echo "Next steps:"
echo "1. Verify the job was created in Jenkins at: ${JENKINS_URL}/job/${JOB_NAME}/"
echo "2. Check GitHub repository settings to confirm webhook was created"
echo "3. Make a small change to your repository and push it to test the webhook"

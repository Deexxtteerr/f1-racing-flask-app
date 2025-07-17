pipeline {
    agent any
    
    // This pipeline is configured to be triggered automatically by GitHub webhooks
    // No explicit triggers needed in the Jenkinsfile as they're configured at the job level
    
    environment {
        PROJECT_NAME = 'python-flask-app'
        CONTAINER_NAME = 'flask-app'
        PORT = '5000'
        APP_SERVER = '98.82.10.4'  // Updated with the actual Python app server IP
        SSH_CREDENTIALS = 'python-app-ssh-key'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '🚀 Starting Python Flask App Pipeline...'
                checkout scm
            }
        }
        
        stage('Setup Python Environment') {
            steps {
                echo '🐍 Setting up Python environment...'
                sh '''
                    python -m venv venv || python3 -m venv venv
                    . venv/bin/activate
                    pip install -r requirements.txt
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '🧪 Running tests...'
                sh '''
                    . venv/bin/activate
                    # Add your test commands here
                    # For example: pytest
                    echo "Tests would run here"
                '''
            }
        }
        
        stage('Docker Build') {
            steps {
                echo '🐳 Building Docker image...'
                sh 'docker build -t ${PROJECT_NAME} .'
            }
        }
        
        stage('Deploy to App Server') {
            steps {
                echo '🚀 Deploying to application server...'
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                        # Create deployment directory if it doesn't exist
                        ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER} "mkdir -p /opt/python-deployment"
                        
                        # Copy necessary files to the server
                        scp -o StrictHostKeyChecking=no -r app requirements.txt Dockerfile ubuntu@${APP_SERVER}:/opt/python-deployment/
                        
                        # Deploy on remote server
                        ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER} "
                            cd /opt/python-deployment
                            docker build -t ${PROJECT_NAME} .
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                            docker run -d -p ${PORT}:5000 --name ${CONTAINER_NAME} ${PROJECT_NAME}
                        "
                    '''
                }
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '✅ Verifying deployment...'
                sh '''
                    sleep 10
                    curl -f http://${APP_SERVER}:${PORT}/ || exit 1
                '''
                echo '🎉 Python Flask App is deployed!'
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline completed successfully!'
            echo '🌐 Application URL: http://${APP_SERVER}:${PORT}/'
            
            // Notify on successful deployment - uncomment and configure as needed
            // slackSend channel: '#deployments', color: 'good', message: "Deployment of ${env.PROJECT_NAME} successful!"
        }
        failure {
            echo '❌ Pipeline failed!'
            
            // Notify on failed deployment - uncomment and configure as needed
            // slackSend channel: '#deployments', color: 'danger', message: "Deployment of ${env.PROJECT_NAME} failed!"
        }
        always {
            echo '📋 Pipeline completed for Python Flask App'
            // Clean up workspace
            sh 'rm -rf venv'
        }
    }
}

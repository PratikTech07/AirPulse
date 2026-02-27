pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'pratiktech07'
        DOCKER_IMAGE_NAME = "${DOCKER_HUB_USER}/airpulse"
        HELM_REPO_URL = "github.com/PratikTech07/HelmChartForAirpulse.git"
        // This binds DOCKER_HUB_USR and DOCKER_HUB_PSW from the credential ID
        DOCKER_HUB = credentials('docker-hub-credentials')
        // Corrected HELM_REPO_TOKEN binding
        HELM_TOKEN = credentials('helm-repo-token')
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                    // Set IMAGE_TAG dynamically after checkout
                    env.IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Starting build for tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                sh "echo $DOCKER_HUB_PSW | docker login -u $DOCKER_HUB_USR --password-stdin"
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} ."
                sh "docker tag ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                sh "docker push ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
                sh "docker push ${DOCKER_IMAGE_NAME}:latest"
            }
        }

        stage('Update Helm Chart') {
            steps {
                sh """
                    # Clean up any existing directory
                    rm -rf HelmChartForAirpulse
                    
                    # Clone the Helm repository using the token
                    git clone https://${HELM_TOKEN}@${HELM_REPO_URL}
                    cd HelmChartForAirpulse/airpulse-chart

                    # Configure Git
                    git config user.name "Jenkins Pipeline"
                    git config user.email "jenkins@airpulse.com"

                    # Update the image tag in values.yaml
                    sed -i "s|tag:.*|tag: \\"${env.IMAGE_TAG}\\"|" values.yaml

                    # Commit and push the changes
                    git add values.yaml
                    git commit -m "Update AirPulse image tag to ${env.IMAGE_TAG} [Jenkins Build #${env.BUILD_NUMBER}]"
                    git push origin main
                """
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
    }
}

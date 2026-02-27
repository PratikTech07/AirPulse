pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'pratiktech07'
        DOCKER_IMAGE_NAME = "${DOCKER_HUB_USER}/airpulse"
        HELM_REPO_URL = "github.com/PratikTech07/HelmChartForAirpulse.git"
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
                script {
                    // Using standard withCredentials for better transparency
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${env.IMAGE_TAG}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Update Helm Chart') {
            steps {
                // This assumes you have a secret text credential with ID 'helm-repo-token'
                withCredentials([string(credentialsId: 'helm-repo-token', variable: 'HELM_REPO_TOKEN')]) {
                    sh """
                        # Clean up any existing directory
                        rm -rf HelmChartForAirpulse
                        
                        # Clone the Helm repository
                        git clone https://${HELM_REPO_TOKEN}@${HELM_REPO_URL}
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

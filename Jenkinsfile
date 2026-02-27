pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = 'pratiktech07'
        DOCKER_IMAGE_NAME = "${DOCKER_HUB_USER}/airpulse"
        HELM_REPO_URL = "github.com/PratikTech07/HelmChartForAirpulse.git"
        IMAGE_TAG = "${env.GIT_COMMIT.take(7)}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    // This assumes you have credentials with ID 'docker-hub-credentials' in Jenkins
                    docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials') {
                        def customImage = docker.build("${DOCKER_IMAGE_NAME}:${IMAGE_TAG}")
                        customImage.push()
                        customImage.push("latest")
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
                        sed -i "s|tag:.*|tag: \"${IMAGE_TAG}\"|" values.yaml

                        # Commit and push the changes
                        git add values.yaml
                        git commit -m "Update AirPulse image tag to ${IMAGE_TAG} [Jenkins Build #${env.BUILD_NUMBER}]"
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

pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        DOCKER_CREDENTIALS_ID = "dockerhub-token"
    }

    stages {
        stage('Cleanup') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                // The implicit checkout is not enough for the declarative pipeline,
                // so we include the explicit git step here.
                git branch: 'main', url: 'https://github.com/Shubham-Sharma-7/devops-todo-automation.git'
            }
        }

        stage('Build & Test') {
            steps {
                // Use default Maven goals for package and test execution
                sh 'mvn clean package'
            }
        }

        // --- CORRECTED STAGE: Uses shell commands for guaranteed stability ---
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                    // Use standard shell command for building and tagging
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Authenticating to Docker Hub and pushing image..."
                    // Use the canonical registry URL and secure credential ID
                    docker.withRegistry('https://index.docker.io', DOCKER_CREDENTIALS_ID) {

                        // Use shell commands for pushing and tagging
                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Verify Push') {
            steps {
                // This verifies the image is accessible from the registry after the push
                sh "docker pull ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
            }
        }
    }

    post {
        success {
            echo "✅ Build ${BUILD_NUMBER} pushed successfully to ${DOCKER_IMAGE_NAME}"
        }
        failure {
            echo "❌ Build failed — check logs and Docker credentials."
        }
        always {
            cleanWs()
        }
    }
}
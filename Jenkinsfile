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
                git branch: 'main', url: 'https://github.com/Shubham-Sharma-7/devops-todo-automation.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean package -DskipTests=false'
            }
        }

        // Build Docker image via shell (reliable on macOS)
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        // Push Docker image using shell + docker.withRegistry
        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io', DOCKER_CREDENTIALS_ID) {
                        echo "Pushing ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} to Docker Hub"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        echo "Tagging as latest..."
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Verify Push') {
            steps {
                sh "docker pull ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                sh "docker images ${DOCKER_IMAGE_NAME}"
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

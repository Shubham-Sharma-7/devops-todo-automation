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

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                    app = docker.build("${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "Authenticating to Docker Hub and pushing image..."
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDENTIALS_ID) {
                        app.push("${BUILD_NUMBER}")
                        app.push("latest")
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

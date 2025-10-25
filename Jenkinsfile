pipeline {
    agent any

    tools {
        // These names must match Jenkins > Manage Jenkins > Tools configuration
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        // All lowercase for Docker Hub registry compliance
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        // The ID of the credential storing your Access Token
        DOCKER_CREDENTIALS_ID = "dockerhub-token"
    }

    stages {
        // Stage 1: Clean the workspace before starting
        stage('Cleanup') {
            steps {
                cleanWs()
            }
        }

        // Stage 2: Get the latest code from GitHub
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Shubham-Sharma-7/devops-todo-automation.git'
            }
        }

        // Stage 3: Build the Java application and Run Tests
        stage('Build & Test') {
            steps {
                // This phase includes compilation, running unit tests, and packaging
                sh 'mvn clean package'
            }
        }

        // Stage 4: Build the Docker image
        stage('Build Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        // Stage 5: Push Image (Using official docker.withRegistry for secure authentication)
        stage('Push Image') {
            steps {
                script {
                    // This securely uses the credential ID to authenticate to Docker Hub (index.docker.io is the canonical registry URL)
                    docker.withRegistry('https://index.docker.io', DOCKER_CREDENTIALS_ID) {

                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }
}
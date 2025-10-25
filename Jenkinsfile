pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        // Your Docker Hub username and repository (Must be lowercase for image naming)
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        // The Credential ID for your Docker Hub Access Token
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
                // Runs Maven phases: compile, test (from pom.xml), package
                sh 'mvn clean package'
                sh 'mvn test'
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

        // Stage 5: Push Image (Using official docker.withRegistry for authentication)
        stage('Push Image') {
            steps {
                script {
                    // Use the internal Docker client integration and credentials store
                    // --- CHANGED LINE: Using the standard Docker Hub registry URL
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
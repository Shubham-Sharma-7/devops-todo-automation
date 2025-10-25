pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
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

        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Build Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        // --- THIS STAGE IS REPLACED ---
        stage('Push Image') {
            steps {
                // Use withCredentials to securely load username and password(token) into variables
                withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PAT')]) {
                    script {
                        // Explicitly login using password-stdin (more secure)
                        // Note: We use DOCKER_PAT here, which holds your Access Token
                        sh "echo ${DOCKER_PAT} | docker login -u ${DOCKER_USER} --password-stdin"

                        // Push the image with the build number tag
                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"

                        // Tag as 'latest' and push
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"

                        // Good practice: Logout after pushing
                        sh "docker logout"
                    }
                }
            }
        }
        // --- END OF REPLACED STAGE ---
    }
}
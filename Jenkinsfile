pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        DOCKER_CREDENTIALS_ID = "dockerhub-token"
        // 1. Create a dedicated, isolated config directory for this build
        DOCKER_CONFIG = "${env.WORKSPACE}/.docker-config"
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
                sh 'mvn clean package'
            }
        }

        stage('Build Image') {
            steps {
                // 2. Tell the build command to use our isolated config
                sh "docker --config ${DOCKER_CONFIG} build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        // --- THE FINAL PUSH STAGE FIX ---
        stage('Push Image') {
            steps {
                // 3. Create the clean config directory
                sh "mkdir -p ${DOCKER_CONFIG}"
                // 4. Securely load credentials
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PAT')]) {
                    script {
                        // 5. Log in, forcing it to write to OUR config file
                        sh "echo ${DOCKER_PAT} | docker --config ${DOCKER_CONFIG} login -u ${DOCKER_USER} --password-stdin"

                        // 6. Push, forcing it to READ from OUR config file
                        sh "docker --config ${DOCKER_CONFIG} push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"

                        // 7. Tag, forcing it to READ from OUR config file
                        sh "docker --config ${DOCKER_CONFIG} tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"

                        // 8. Push, forcing it to READ from OUR config file
                        sh "docker --config ${DOCKER_CONFIG} push ${DOCKER_IMAGE_NAME}:latest"

                        // 9. Logout, forcing it to use OUR config file
                        sh "docker --config ${DOCKER_CONFIG} logout"
                    }
                }
            }
        }
        // --- END OF FIX ---
    }

    post {
        always {
            // Clean up the workspace and our temporary docker config
            cleanWs()
        }
    }
}
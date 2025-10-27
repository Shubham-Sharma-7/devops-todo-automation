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
                sh 'mvn clean package'
            }
        }

        stage('Build Image') {
            steps {
                sh "mkdir -p ${env.WORKSPACE}/.docker-config"
                sh "docker --config ${env.WORKSPACE}/.docker-config build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        stage('Push Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PAT')]) {
                    script {
                        sh "echo ${DOCKER_PAT} | docker --config ${env.WORKSPACE}/.docker-config login -u ${DOCKER_USER} --password-stdin"
                        sh "docker --config ${env.WORKSPACE}/.docker-config push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "docker --config ${env.WORKSPACE}/.docker-config tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker --config ${env.WORKSPACE}/.docker-config push ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker --config ${env.WORKSPACE}/.docker-config logout"
                    }
                }
            }
        }

        // --- THIS STAGE REPLACES THE ANSIBLE STAGE ---
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Applying Kubernetes manifests...'
                    // We need to tell kubectl where our cluster is.
                    // For Docker Desktop, it's 'docker-desktop'.
                    sh 'kubectl config use-context docker-desktop'

                    // Apply the deployment and service files from our repo
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'

                    // This is the most important command.
                    // It tells K8s to update the running deployment with the new image.
                    sh "kubectl rollout restart deployment todo-app-deployment"
                }
            }
        }
        // --- END OF NEW STAGE ---
    }

    post {
        always {
            cleanWs()
        }
    }
}
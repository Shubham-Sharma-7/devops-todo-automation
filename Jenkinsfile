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

        // --- THIS STAGE IS UPDATED ---
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    echo 'Applying Kubernetes manifests...'

                    // 1. Select the context (this worked)
                    sh 'kubectl config use-context docker-desktop'

                    // 2. --- THIS IS THE FIX ---
                    // Tell kubectl to use the name that matches the SSL certificate
                    sh 'kubectl config set-cluster docker-desktop --server=https://kubernetes.docker.internal:6443'

                    // 3. Apply the manifests
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl apply -f service.yaml'

                    // 4. Trigger the rolling update
                    sh "kubectl rollout restart deployment todo-app-deployment"
                }
            }
        }
        // --- END OF UPDATE ---
    }

    post {
        always {
            cleanWs()
        }
    }
}
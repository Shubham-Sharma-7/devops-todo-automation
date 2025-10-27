pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        DOCKER_CREDENTIALS_ID = "dockerhub-token"
        // This is the ID for our new vault password credential
        ANSIBLE_VAULT_CRED_ID = "ansible-vault-pass"
    }

    stages {
        // Stage 1: Clean the workspace
        stage('Cleanup') {
            steps {
                cleanWs()
            }
        }

        // Stage 2: Get code from GitHub
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Shubham-Sharma-7/devops-todo-automation.git'
            }
        }

        // Stage 3: Build & Test
        stage('Build & Test') {
            steps {
                sh 'mvn clean package'
            }
        }

        // Stage 4: Build Docker Image
        stage('Build Image') {
            steps {
                // We use our isolated config to avoid keychain bugs
                sh "mkdir -p ${env.WORKSPACE}/.docker-config"
                sh "docker --config ${env.WORKSPACE}/.docker-config build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
            }
        }

        // Stage 5: Push Docker Image
        stage('Push Image') {
            steps {
                // We log in and push using our isolated config
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

        // --- NEW STAGE: DEPLOYMENT ---
        stage('Deploy to Production') {
            steps {
                script {
                    // This securely loads the ansible-vault-pass into a variable
                    withCredentials([string(credentialsId: env.ANSIBLE_VAULT_CRED_ID, variable: 'VAULT_PASS')]) {
                        // We pass the vault password to Ansible using an environment variable
                        // This is a secure and standard way to do it.
                        sh "ANSIBLE_VAULT_PASSWORD=${VAULT_PASS} ansible-playbook -i inventory.ini deploy-app.yml -e '@vault.yml'"
                    }
                }
            }
        }
        // --- END OF NEW STAGE ---
    }

    post {
        always {
            cleanWs() // Always clean the workspace
        }
    }
}
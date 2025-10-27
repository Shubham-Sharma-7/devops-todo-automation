pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        DOCKER_CREDENTIALS_ID = "dockerhub-token"
        // ID for the vault.yml file
        ANSIBLE_VAULT_FILE_ID = "ansible-vault-file"
        // ID for the vault-pass.txt file
        ANSIBLE_VAULT_PASS_FILE_ID = "ansible-vault-pass-file"
    }

    stages {
        // ... (Cleanup, Checkout, Build, Build Image, Push Image stages are all perfect) ...

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

        // --- FINAL DEPLOY STAGE ---
        stage('Deploy to Production') {
            steps {
                script {
                    // Load BOTH secret files
                    withCredentials([
                        file(credentialsId: env.ANSIBLE_VAULT_FILE_ID, variable: 'VAULT_FILE_PATH'), // Path to vault.yml
                        file(credentialsId: env.ANSIBLE_VAULT_PASS_FILE_ID, variable: 'VAULT_PASS_FILE_PATH') // Path to vault-pass.txt
                    ]) {
                        // This command tells Ansible to use the vault-pass.txt file as its password
                        sh "ansible-playbook -i inventory.ini deploy-app.yml -e '@${VAULT_FILE_PATH}' --vault-password-file ${VAULT_PASS_FILE_PATH}"
                    }
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
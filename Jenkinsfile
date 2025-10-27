pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        DOCKER_CREDENTIALS_ID = "dockerhub-token"
        ANSIBLE_VAULT_CRED_ID = "ansible-vault-pass"
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

        // --- UPDATED DEPLOY STAGE (REMOVED 'tools' BLOCK) ---
        stage('Deploy to Production') {
            steps {
                script {
                    withCredentials([string(credentialsId: env.ANSIBLE_VAULT_CRED_ID, variable: 'VAULT_PASS')]) {
                        // This 'sh' command will now work because Ansible is installed in the container
                        sh "ANSIBLE_VAULT_PASSWORD=${VAULT_PASS} ansible-playbook -i inventory.ini deploy-app.yml -e '@vault.yml'"
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
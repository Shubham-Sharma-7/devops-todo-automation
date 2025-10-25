pipeline {
    // 1. Agent: Where will this pipeline run?
    agent any

    // 2. Tools: Define tools to be used
    tools {
        // These 'maven' and 'jdk' names must match the ones in
        // your Jenkins Global Tool Configuration.
        maven 'M3'
        jdk 'JDK 17'
    }

    // 3. Environment: Set up variables
    environment {
        // This is the Docker Hub username/repo-name we've been using
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        // This is the ID of the credentials we saved in Jenkins
        DOCKER_CREDENTIALS_ID = "docker-hub-credentials"
    }

    // 4. Stages: The actual work, broken into steps
    stages {
        // --- THIS IS THE NEW STAGE ---
        stage('Cleanup') {
            steps {
                // This command wipes the current workspace!
                cleanWs()
            }
        }
        // --- END OF NEW STAGE ---

        // STAGE 2: Get the code
        stage('Checkout') {
            steps {
                // This is a built-in Jenkins command to pull code from Git
                git branch: 'main', url: 'https://github.com/Shubham-Sharma-7/devops-todo-automation.git'
            }
        }

        // STAGE 3: Build the Java application
        stage('Build') {
            steps {
                // Run the Maven 'clean package' command
                sh 'mvn clean package'
            }
        }

        // STAGE 4: Run Tests
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        // STAGE 5: Build the Docker Image
        stage('Build Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        // STAGE 6: Push the Docker Image
        stage('Push Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: DOCKER_CREDENTIALS_ID) {
                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }
}
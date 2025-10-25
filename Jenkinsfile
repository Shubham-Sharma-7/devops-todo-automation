pipeline {
    // 1. Agent: Where will this pipeline run?
    // 'any' means Jenkins can use any available agent/computer.
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
        // STAGE 1: Get the code
        stage('Checkout') {
            steps {
                // This is a built-in Jenkins command to pull code from Git
                git branch: 'main', url: 'https://github.com/Shubham-Sharma-7/devops-todo-automation.git'
            }
        }

        // STAGE 2: Build the Java application
        stage('Build') {
            steps {
                // Run the Maven 'clean package' command
                // 'sh' means "shell command"
                sh 'mvn clean package'
            }
        }

        // STAGE 3: Run Tests
        stage('Test') {
            steps {
                // This fulfills your resume point: "run tests"
                sh 'mvn test'
            }
        }

        // STAGE 4: Build the Docker Image
        stage('Build Image') {
            steps {
                script {
                    // Use the 'docker' command.
                    // We tag it with the build number (e.g., :1, :2) to create unique versions
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        // STAGE 5: Push the Docker Image
        stage('Push Image') {
            steps {
                script {
                    // This 'withDockerRegistry' block is from the 'Docker Pipeline' plugin
                    // It will automatically use our 'docker-hub-credentials'
                    withDockerRegistry(credentialsId: DOCKER_CREDENTIALS_ID) {
                        // Push the image we just built
                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"

                        // Also push a 'latest' tag for convenience
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }
}
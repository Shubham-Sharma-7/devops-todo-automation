pipeline {
    agent any

    tools {
        maven 'M3'
        jdk 'JDK 17'
    }

    environment {
        // Your Docker Hub username and repository
        DOCKER_IMAGE_NAME = "shubhamsharma1975/devops-todo-automation"
        // The Credential ID for your Docker Hub Access Token
        DOCKER_CREDENTIALS_ID = "dockerhub-token"
    }

    stages {
        // Stage 1: Clean the workspace before starting
        stage('Cleanup') {
            steps {
                // Wipes the directory Jenkins uses for this job
                cleanWs()
            }
        }

        // Stage 2: Get the latest code from GitHub
        stage('Checkout') {
            steps {
                // Clones your repository's main branch
                git branch: 'main', url: 'https://github.com/Shubham-Sharma-7/devops-todo-automation.git'
            }
        }

        // Stage 3: Build the Java application using Maven
        stage('Build') {
            steps {
                // Runs 'mvn clean package' which compiles, tests (by default), and packages the app
                sh 'mvn clean package'
            }
        }

        // Stage 4: Run automated tests using Maven
        stage('Test') {
            steps {
                // Explicitly runs the test phase
                sh 'mvn test'
            }
        }

        // Stage 5: Build the Docker image using the Dockerfile
        stage('Build Image') {
            steps {
                script {
                    // Builds the image and tags it with the Jenkins build number (e.g., :1, :2, etc.)
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ."
                }
            }
        }

        // Stage 6: Push Image (Using direct password flag)
        stage('Push Image') {
            steps {
                // Securely load Docker Hub username and Access Token into variables
                withCredentials([usernamePassword(credentialsId: env.DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PAT')]) {
                    script {
                        // Construct the command directly in Groovy, embedding the PAT
                        // Jenkins will mask the PAT value in the console output
                        sh """
                            docker login -u ${DOCKER_USER} -p ${DOCKER_PAT}
                        """

                        // Push the image with the build number tag
                        sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"

                        // Tag as 'latest' and push
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER} ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"

                        // Log out from Docker Hub
                        sh "docker logout"
                    }
                }
            }
        }
    }
}
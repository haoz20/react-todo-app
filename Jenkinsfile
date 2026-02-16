pipeline {
    agent {
        docker { 
            image 'node:18-alpine'
        }
    }
    

    environment {
        IMAGE_NAME = 'finead-todo-app'
        DOCKER_HUB_CREDS = 'docker-hub-credentials'
        IMAGE_TAG = 'latest'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Test') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_HUB_CREDS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_HUB_CREDS}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker push ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    """
                }
            }
        }
    }

    post {
        always {
            // Clean workspace + local docker image
            cleanWs()

            // Best-effort cleanup (won't fail pipeline)
            withCredentials([usernamePassword(
                credentialsId: "${DOCKER_HUB_CREDS}",
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {
                sh """
                    docker rmi ${DOCKER_USER}/${IMAGE_NAME}:${IMAGE_TAG} || true
                """
            }
        }
    }
}

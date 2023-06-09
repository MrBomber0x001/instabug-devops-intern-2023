pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub')
    }
    stages {
        stage('Build') {
            steps {
                script {
                    // dockerImage = docker.build('instabug-go', '-f Dockerfile .')
                    sh 'docker build -t yousefmeska/instabug-go:latest .'
                }
            }
        }

        stage('Login') {
            steps {
                script {
                    echo "Attempting to log in to DockerHub"
                    sh 'docker login -u ${DOCKER_HUB_CREDENTIALS_USR} -p ${DOCKER_HUB_CREDENTIALS_PSW}'
                }
            }
        }
        stage('Push to Docker repo') {
            steps {
                script {
                    sh 'docker push yousefmeska/instabug-go:latest'
                }
            }
        }
    }
    post {
        always {
            sh 'docker logout'
        }
    }
}
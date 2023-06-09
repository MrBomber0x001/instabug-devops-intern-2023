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
                    sh 'docker build -t yousefmeska/instabug-go .'
                }
            }
        }

        stage('Login') {
            steps {
                script {
                    echo "Attempting to log in to DockerHub"
                    sh 'docker login -u yousefmeska -p dckr_pat_HTDdCiQS7UY99yPnKO3_8MqeyW8'
                }
            }
        }
        stage('Push to Docker repo') {
            steps {
                script {
                    sh 'docker push yousefmeska/instabug-go'
                }
            }
        }
        
    }
}
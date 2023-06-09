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

        stage('Login_Push') {
            steps {
                script {
                    echo "Logging"
                    sh 'docker login -u yousefmeska -p dckr_pat_HTDdCiQS7UY99yPnKO3_8MqeyW8'
                    sh 'docker push yousefmeska/instabug-go'
                }
            }
        }
        
    }
}
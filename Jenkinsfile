pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub')
    }
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build('instabug-go', '-f Dockerfile .')
                }
            }
        }

        stage('Login_Push') {
            steps {
                script {
                    sh "echo 'welcome'"
                }
            }
        }
    }
}
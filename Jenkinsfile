pipeline {
    agent any
    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub')
    }
    stages {
        stage('Build') {
            steps {
                script {
                    dockerImage = docker.build('instabug-go', '-f Dockerfile .')
                }
            }
        }

        stage('Login_Push') {
            steps {
                script {
                    docker.withRegistry('https://registry.dockerhub.com', 'dockerhub') {
                        docker.image('instabug-go').push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
        
    }
}
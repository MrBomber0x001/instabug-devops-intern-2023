pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build('instabug-go', '-f Dockerfile .')
                }
            }
        }
        
        stage('Push') {
            steps {
                script {
                    docker.withRegistry('https://registry.dockerhub.com', 'docker-hub-repo') {
                        docker.image('instabug-go').push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
    }
}
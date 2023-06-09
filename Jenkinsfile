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

        stage('Login') {
            steps {
                script {
                    bat 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                }
            }
        }
        
        stage('Push') {
            steps {
                script {
                    try {
                        docker.withRegistry('https://registry.dockerhub.com', 'dockerhub') {
                            docker.image('instabug-go').push("${env.BUILD_NUMBER}")
                        }
                    } catch (err) {
                        error(err)
                    }
                }
            }
        }
    }
}
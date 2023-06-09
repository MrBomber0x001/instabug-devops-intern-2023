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
                    bat "echo $DOCKER_HUB_CREDENTIALS_PSW | docker login -u $DOCKER_HUB_CREDENTIALS_PSW --password-stdin"
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
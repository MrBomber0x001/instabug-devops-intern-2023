pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    try {
                        docker.build('instabug-go', '-f Dockerfile .')
                    } catch (err) {
                        currentBuild.result = 'FAILURE'
                        error(err)
                    }
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    try {
                        docker.image('instabug-go').inside {
                            sh 'go test ./...'
                        }
                    } catch (err) {
                        currentBuild.result = 'FAILURE'
                        error(err)
                    }
                }
            }
        }
        stage('Push') {
            steps {
                script {
                    docker.withRegistry('https://registry.dockerhub.com', 'docker-hub-repo') {
                        docker.image('my-app').push("${env.BUILD_NUMBER}")
                    }
                }
            }
        }
    }
}
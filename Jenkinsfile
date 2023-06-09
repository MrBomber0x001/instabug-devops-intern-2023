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
                    echo "Building the docker image"
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'PASS', usernameVariable: 'USER')]){
                        sh 'docker build -t yousefmeska/instabug-go:v1 .'
                        sh "docker login -u $USER -p $PASS"
                        sh 'docker push yousefmeska/instabug-go:v1'
                    }
                }
            }
        }
    }
}
# Instabug - Infrastructure internship 2023

This file contains

- Dockerfile and Docker compose documentation
- Jenkins Pipeline Documentation
- Native K8s documentation
- Helm Documentation
- The bug solution
- ArgoCD documentation

I've been presented with a Document containing a `lightweight go web server` that should be dockerized and pipelined through Jenkins

First thing I've encoutered was reading the source code and understand it as much as I could to have a context of what I am about to work on.

Then, I began to dockerize the application by choosing a secure and lightweight alpine image to base official go image on.

## Docker

### Dockerfile

The Dockerfile is based on a `multi-stage build` strategy for better optimization

```sh
FROM golang:1.20.4-alpine3.16

# Set the working directory to /app
WORKDIR /app

# Copy the source code into the container
COPY . .

# Build the binary
RUN go build -o app

# Create a new lightweight image without the build dependencies
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /app/app .
COPY wait-for.sh .

EXPOSE 9090
# Set the container command
CMD ["./app"]
```

To run it locally

```sh
docker build it go-instabug:v1 .
docker run -it --name my-go-intern -p9090:9090 go-intern:v1
```

### Dockercompose (test local)

Provided with `.env` files that contains all of the credentials for the app and db to successfully run

```sh
MYSQL_HOST=db
MYSQL_DATABASE=internship
MYSQL_PASS=password
MYSQL_PORT=3306
MYSQL_USER=mysql
MYSQL_ROOT_PASSWORD=password
MYSQL_PASSWORD=password
```

Then I've created A folder names `compose` to put all of the docker compose related files

creating `docker-compose.yml` file which compose the application and the db with a `persisent volume`

```sh
version: '3'
services:
  db:
    image: mysql:latest
    container_name: db
    restart: always
    env_file:
      - .env
    volumes:
      - ./mysql:/var/lib/mysql
    ports:
      - "3306:3306"

  app:
    image: meska-app:latest
    build:
      context: ../
      dockerfile: Dockerfile
    ports:
      - "9090:9090"
    depends_on:
      - db
    env_file:
      - .env
    command: sh -c './wait-for.sh db:3306 -- ./app'

```

In order to fire up the containers, run:

```sh
docker-compose up --build
```

the output should be something looks like this:

![](./screenshots/Screenshot%202023-06-09%20233513.png)

### Running and Testing the application

Navigating to `/healthcheck` to ensure all of the steps have gone right

![](./screenshots/Q552U11%20(1).png)

using `curl` to make requests the application from the cli

![](./screenshots/QYFzII7.png)

## Jenkins

The pipeline architecture as follows

```sh
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
                    try { 
                        echo "building the docker image"
                        sh 'docker build -t yousefmeska/instabug-go:latest .'
                    } catch (Exception err){
                        currentBuild.result = 'FAILURE'
                        error(err)
                        sh 'exit 1'
                    }
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
                    echo "Publishing to docker repo"
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
```

The pipeline status

![](./screenshots/Screenshot%202023-06-09%20172949.png)

And here's the Docker repo after pushing the image
![](./screenshots/Screenshot%202023-06-09%20173137.png)

## Helm

the helm directory all of the required manifests for the k8s cluster.

I've choosed to use a `mysql` chart instead of configuring it myself, to save time for the bonus section as much as I can.

```sh
helm install mysql --values ./helm/test-mysql.yml
```

The `test-mysql.yml` file contains configuration and credentials for mysql to be deployed successfully.

```yml
architecture: replication
secondary:
  replicaCount: 3
persistence:
  storageClass: "standard"
auth:
  rootPassword:
  database: "internship"
  username: "mysql"
  password: "password"
```

I've configured mysql to have 1 primary and 3 other replicas for high availability.

Checking the output

```
kubectl get all
NAME                    READY   STATUS    RESTARTS   AGE
pod/mysql-primary-0     1/1     Running   0          4m49s
pod/mysql-secondary-0   1/1     Running   0          4m49s
pod/mysql-secondary-1   1/1     Running   0          2m16s
pod/mysql-secondary-2   1/1     Running   0          94s

NAME                               TYPE        CLUSTER-IP      EXT
service/kubernetes                 ClusterIP   10.96.0.1       <no
service/mysql-primary              ClusterIP   10.111.225.41   <no
service/mysql-primary-headless     ClusterIP   None            <no
service/mysql-secondary            ClusterIP   10.101.186.36   <no
service/mysql-secondary-headless   ClusterIP   None            <no

NAME                               READY   AGE
statefulset.apps/mysql-primary     1/1     4m49s
statefulset.apps/mysql-secondary   3/3     4m49s
```

- ✅ StatefulSet configured
- ✅ PVC configured and SVC are

Now Let's deploy the Go server

- the docker repo has been pushed using Jenkins pipeline, so we're going to use it as our image.
- Created `configmap.yml` to store all of the necessary configurations
- Created `secret.yml` to store the required secrets for both mysql and go credentials.
- Created `deployment.yml` that actually contain the deployment manifest.

checking pods

```
kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
go-app-d5584fc47-nrnn8   1/1     Running   0          8s
mysql-primary-0          1/1     Running   0          26m
mysql-secondary-0        1/1     Running   0          26m
mysql-secondary-1        1/1     Running   0          23m
mysql-secondary-2        1/1     Running   0          23m
```

exposing the service for testing purposes

```
$ kubectl expose deployment/go-app --type="NodePort" --port 9090  
service/go-app exposed
```

```
$ kubectl port-forward -n default svc/go-app 9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
Handling connection for 9090

```

Testing

```sh
$ curl -X POST http://localhost:9090/
OK

```

## Security Measures and Analysis

To achieve a good security practices I've listed most of the security issues that might happens

- The Dockerfile contains an image that has some potential vulenerabilites
- Credentials are not stored properly in the Docker Compose of Dockerfile
- The pipeline is leaking sensitive information
- The code itself could have code vulenerabilites.

So in each one of the above issues I've used the suitable security best practice as follows

- [x] Used lightweight and Almost zero-vulen image in the `Dockerfile`
- [x] Run Synk CLI test to see if there's container-level security issues
- [x] Stored credentials properly by storing them as environment variable in `.env` and inside Jenkins itself.

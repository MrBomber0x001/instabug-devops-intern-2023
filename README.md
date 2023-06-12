[![Build Status](https://c897-41-239-147-125.eu.ngrok.io/buildStatus/icon?job=insta-bug)](https://c897-41-239-147-125.eu.ngrok.io/job/insta-bug/)

# Wow Such Program

This program is very simple, it connects to a MySQL database based on the following env vars:

* MYSQL_HOST
* MYSQL_USER
* MYSQL_PASS
* MYSQL_PORT

And exposes itself on port 9090:

* On `/healthcheck` it returns an OK message,
* On GET it returns all recorded rows.
* On POST it creates a new row.
* On PATCH it updates the creation date of the row with the same ID as the one specified in query parameter `id`

-----

## Architecture

## Tools used

* `Docker`
* `Kubernetes`
* `Go`
* `Minikube`
* `Helm`
* `wait-for`
* `Jenkins`
* `ArgoCD`

## Projet structure

```
- docs # contains documentation files
  - bug_solution.md
  - documentation.md
  - screenshots
- helm # helm charts
- compose # contain docker compose related files
- manifests # contain kubernetes files
```

## The Bug

The bug was that 'GET' request returns empty array of objects like `[{}, {}, {}]` even the `POST` request returned `OK`

```sh
curl http://localhost:9090
[{}, {}, {}]
```

![](./docs/screenshots/Screenshot%202023-06-11%20061635.png)

However the data is actually stored on the db successfully

![](./docs/screenshots/Screenshot%202023-06-11%20074536.png)

The problem was that the struct members are 'lower-cased' which can't be used in the API response.
I've solved it by capitalizing the first Letter of each member

```go
type row struct {
 ID        int64     `json:"id"`
 CreatedAt time.Time `json:"created_at"`
}
```

And It worked 🎉

![](./docs/screenshots/Screenshot%202023-06-11%20082139.png)

Another issue (not a bug) I've encountered was when trying to run `docker compose` that the server is started before the db was actually ready (not the container itself is up and running, but mysql db is ready for connections).

One of the solutions I though of was

1. add a timeout to wait for the connection to be ready, although it didn't go very well 😥
2. to use a `wait-for` script, to ensure that the web server won't start unless the db is fully ready! and it did work 🎉

## Screenshots of the application workings

![](./docs/screenshots/Screenshot%202023-06-11%20061635.png)

---

I've been presented with a Document containing a `lightweight go web server` that should be dockerized and pipelined through Jenkins

First thing I've encoutered was reading the source code and understand it as much as I can to have a context of what I am about to work with.

Then, I've begin to dockerize the application by choosing a secure and lightweight alpine image

## Docker

### Dockerfile

I've choosed alpine-16 as it's a lightweight distri and this version specifically is secure as I've searched Dockerhub for most secure alpine version it has almost zero vulenerabilites.

The Dockerfile is based on Multi-stage build strategy

```sh
FROM golang:1.16-alpine

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

![](./docs/screenshots/Screenshot%202023-06-09%20233513.png)

### Running and Testing the application

Navigating to `/healthcheck` to ensure all of the steps have gone right

![](./docs/screenshots/Q552U11%20(1).png)

using `curl` to make requests the application from the cli

![](./docs/screenshots/QYFzII7.png)

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

![](./docs/screenshots/Screenshot%202023-06-09%20172949.png)

And here's the Docker repo after pushing the image
![](./docs/screenshots/Screenshot%202023-06-09%20173137.png)

## Helm

## Bonus points

### Security Measures and Analysis

To achieve a good security practices I've listed most of the security issues that might happens

* The Dockerfile contains an image that has some potential vulenerabilites
* Credentials are not stored properly in the Docker Compose of Dockerfile
* The pipeline is leaking sensitive information
* Credentials passed to Helm templates are not encoded

So in each one of the above issues I've used the suitable security best practice as follows

* [x] Used lightweight and Almost zero-vulen image in the `Dockerfile`
* [x] Run Synk CLI test to see if there's container-level security issues
* [x] Stored credentials properly by storing them as environment variable in `.env` and inside Jenkins itself.
* [x] Encoded credentials passed to Helm as `base64`

### ArgoCD with Helm

## Logs

* [x] Docker
  * [x] Dockerfile
  * [x] Docker Compose
  * [x] Testing and running the application

* [x] Setup Jenkins
  * [x] Installing and building tools
  * [x] creating Github WebHook and Use Github Credentials in Jenkins
  * [x] creating the docker hub credentials for docker inside jenkins
  * [x] Finish the pipeline
    * [x] If error was in the build [report it]
    * [x] unless, push it to dockerhub
    * [x] use credentials as environment variables for security best practices
    * [x] build status

* [ ] Helm
  * [ ] Add autoscaling manifest for number of replicas.
* [ ] Add argocd app that points to helm manifests to apply gitops
concept.
* [x] Secure your containers as much as you can.
  * [x] Choosed lightweight and secure docker image
  * [x] Run Code and Container security analysis using `Synk`
  * [x] Added Additional stage in the Jenkins Pipeline before pushing to Docker repo
* [x] Fix a bug in the code that would appear when you test the api

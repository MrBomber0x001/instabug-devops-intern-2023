
## Docker

### Dockerfile

I've choosed alpine-16 specically because it has almost zero vulenerabilites.

```sh
# Use a lightweight base image
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

# Set the container command
CMD ["./app"]
```

```sh
docker build -t go-intern:v1 .
```

```sh
docker run -it --name my-go-intern -p9090:9090 go-intern:v1
```

### Dockercompose (test local)

Provided with `.env` files that contains

```sh
version: '3'
services:
  app:
    image: my-app
    ports:
      - "8080:8080"
    depends_on:
      - db
  db:
    image: mysql:latest
    environment:
      - MYSQL_HOST=
      - MYSQL_PASS=
      - MYSQL_PORT=
      - MYSQL_USER=
```

```sh
docker pull mysql:latest
```

```sh
docker-compose up -e MYSQL_=example_password -e POSTGRES_USER=example_user -e POSTGRES_DB=example_db
```

## Jenkins

on ubuntu

```sh
sudo docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

on windows

```sh

```

## Helm

Installing Helm charts

## Synk (Security Analysis)

running synk tests to spot any vulenerabilites or potential security issues

## Bonus points

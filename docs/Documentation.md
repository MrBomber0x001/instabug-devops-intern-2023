
## Docker

### Dockerfile

I've choosed alpine-16 specically because it has almost zero vulenerabilites.

```sh

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

## Helm

Installing Helm charts

## Synk (Security Analysis)

running synk tests to spot any vulenerabilites or potential security issues

## Bonus points

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
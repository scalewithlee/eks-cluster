# Build stage
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY main.go ./
RUN CGO_ENABLED=0 GOOS=linux go build -o /hash-service

# Final stage
FROM alpine:3.19
WORKDIR /
COPY --from=builder /hash-service /hash-service
ENV HASH_SERVICE_PORT=8080
EXPOSE 8080
CMD ["/hash-service"]

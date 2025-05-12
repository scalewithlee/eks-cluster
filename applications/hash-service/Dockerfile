# Build stage
FROM --platform=$BUILDPLATFORM golang:1.21-alpine AS builder

ARG BUILDPLATFORM
ARG TARGETPLATFORM
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY main.go ./

# Determine architecture based on TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
    GOARCH=amd64; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
    GOARCH=arm64; \
    else \
    GOARCH=amd64; \
    fi && \
    CGO_ENABLED=0 GOOS=linux GOARCH=$GOARCH go build -o /hash-service

# Final stage
FROM --platform=$TARGETPLATFORM alpine:3.19
WORKDIR /
COPY --from=builder /hash-service /hash-service
ENV HASH_SERVICE_PORT=80
EXPOSE 80
CMD ["/hash-service"]

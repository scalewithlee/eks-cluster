# Applications

This directory contains all application source code for services deployed to the EKS cluster.

## Hash Service

The hash service is an HTTP server that:
1. Stores messages and returns their SHA256 hashes
2. Retrieves messages by their hash values

### Directory Structure

```
hash-service/
├── Dockerfile             # Multi-architecture Docker build
├── Makefile               # Build, run and deployment commands
├── README.md              # Service documentation
├── go.mod                 # Go module definition
├── kubernetes/            # Kubernetes deployment manifests
│   ├── deployment.yaml    # Deployment configuration
│   └── service.yaml       # Service (LoadBalancer) configuration
└── main.go                # Application source code
```

### API Endpoints

| Endpoint | Method | Purpose | Example |
|----------|--------|---------|---------|
| `/store` | POST | Store a message and get its hash | `{"message":"Hello"}` |
| `/get` | POST | Retrieve a message by its hash | `{"hash":"2cf24dba..."}` |
| `/health` | GET | Health check | N/A |

### Make Commands

```bash
# Build the Docker image (for current architecture)
make build

# Build for multiple architectures (amd64 and arm64)
make build-multiarch

# Run the container locally
make run

# Push the image to ECR
make push

# Deploy to Kubernetes
make deploy

# Remove from Kubernetes
make undeploy

# Run tests
make test
```

### Example Usage

```bash
# Store a message
curl -X POST -H "Content-Type: application/json" \
  -d '{"message":"Hello!"}' \
  http://localhost:80/store

# Response:
# {"hash":"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f"}

# Retrieve a message
curl -X POST -H "Content-Type: application/json" \
  -d '{"hash":"dffd6021bb2bd5b0af676290809ec3a53191dd81c7f70a4b28688a362182986f"}' \
  http://localhost:80/get

# Response:
# {"message":"Hello!","found":true}
```

## Adding New Applications

To add a new application:

1. Create a new directory under `applications/`
2. Add the application to the `applications` variable in Terraform
3. Follow a similar structure to the hash-service with a Dockerfile, Makefile, and Kubernetes manifests
4. Update the root Makefile to include the new application

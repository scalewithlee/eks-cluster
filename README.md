# EKS Cluster with SHA256 Hash Service

This repository contains infrastructure as code and application code to deploy an EKS cluster on AWS with a simple SHA256 hash service.

## Project Overview

The project consists of:

1. **Infrastructure** - Terraform code to provision an EKS cluster and all required AWS resources
2. **Hash Service** - A simple HTTP service that stores messages and returns their SHA256 hashes
3. **Deployment Configuration** - Kubernetes manifests for deploying the hash service to EKS

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- kubectl
- Docker
- Go 1.21+

## Quick Start

### Infrastructure Deployment

```bash
# Set up remote state storage
cd infrastructure/terraform
./bootstrap.sh --bucket my-tf-state-bucket

# Deploy the infrastructure
cd environments/dev
terraform init
terraform apply
```

### Configure kubectl

```bash
# Update your kubeconfig
aws eks update-kubeconfig --name rigetti --region us-west-2
```

### Build and Deploy Hash Service

```bash
# Build and push the application image
cd applications/hash-service
make build-multiarch
make push

# Deploy to Kubernetes
make deploy
```

## Project Structure

```
.
├── applications/            # Application source code
│   └── hash-service/        # SHA256 hash service implementation
├── configs/                 # Configuration files
│   └── kubernetes/          # Kubernetes manifests
├── infrastructure/          # Infrastructure as code
│   └── terraform/           # Terraform configuration
│       ├── environments/    # Environment-specific configurations
│       └── modules/         # Reusable Terraform modules
```

## Common Commands

```bash
# Format code
make fmt

# Build the hash-service Docker image
cd applications/hash-service && make build

# Push the image to ECR
cd applications/hash-service && make push

# Deploy the hash-service to Kubernetes
cd applications/hash-service && make deploy

# Clean up deployed resources
cd applications/hash-service && make undeploy
cd infrastructure/terraform/environments/dev && terraform destroy
```

## Testing the Service

After deployment, you can test the service using:

```bash
# Get the load balancer URL
LB_URL=$(kubectl get svc hash-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Store a message
curl -X POST -H "Content-Type: application/json" \
  -d '{"message":"Hello!"}' \
  http://$LB_URL/store

# Retrieve a message by hash
curl -X POST -H "Content-Type: application/json" \
  -d '{"hash":"some-hash-value"}' \
  http://$LB_URL/get

# Check the service health
curl http://$LB_URL/health
```

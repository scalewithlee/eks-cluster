# Terraform Infrastructure

This directory contains Terraform code to provision an EKS cluster and all required AWS resources.

## Structure

```
.
├── bootstrap.sh            # Script to set up remote state
├── environments/           # Environment-specific configurations
│   └── dev/                # Development environment
└── modules/                # Reusable Terraform modules
    ├── eks/                # EKS cluster module
    └── foundation/         # Networking and supporting resources
```

## Modules

### Foundation

The foundation module provisions:
- VPC with public and private subnets
- Security groups
- IAM roles
- ECR repositories

### EKS

The EKS module provisions:
- EKS cluster
- Managed node groups
- Cluster add-ons (CoreDNS, kube-proxy, vpc-cni, aws-ebs-csi-driver)
- Access entries for authentication

## Getting Started

### Set up remote state

```bash
# With default settings
./bootstrap.sh

# With custom settings
./bootstrap.sh --bucket your-bucket-name --region us-west-2 --env dev
```

### Deploy to development environment

```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Clean up resources

```bash
cd environments/dev
terraform destroy
```

## Environment Variables

Key terraform variables with their default values:

| Variable | Default | Description |
|----------|---------|-------------|
| region | us-west-2 | AWS region |
| cluster_name | (required) | Name of the EKS cluster |
| cluster_version | 1.32 | Kubernetes version |
| node_instance_types | ["t3.small"] | Instance types for node groups |
| applications | ["hash-service"] | List of applications to create ECR repos for |

Customize variables by editing `terraform.tfvars` or passing variables on the command line:

```bash
terraform apply -var="cluster_name=my-cluster" -var="node_instance_types=[\"t3.medium\"]"
```

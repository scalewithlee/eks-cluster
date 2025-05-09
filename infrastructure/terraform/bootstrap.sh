#!/usr/bin/env bash
# This script will
set -e

usage() {
    echo "Usage $0 [OPTIONS]"
    echo "Bootstrap terraform remote state configuration with an S3 bucket"
    echo ""
    echo "Options:"
    echo "  -b, --bucket BUCKET     S3 bucket name for terraform state (default: my-tf-state-bucket)"
    echo "  -r, --region REGION     AWS region (default: us-west-2)"
    echo "  -e, --env ENV           Environment name for state path (default: dev)"
    echo "  -h, --help              Display this help message"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

# Default configuration
TF_STATE_BUCKET="my-tf-state-bucket"
AWS_REGION="us-west-2"
ENVIRONMENT="dev"

# Parse command-line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--bucket)
            TF_STATE_BUCKET="$2"
            shift 2
            ;;
        -r|--region)
            AWS_REGION="$2"
            shift 2
            ;;
        -e|--env)
            ENVIRONMENT="$3"
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

echo "Using configuration:"
echo "  - S3 bucket: $TF_STATE_BUCKET"
echo "  - AWS region: $AWS_REGION"
echo "  - Env: $ENVIRONMENT"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed. Please install it first."
    exit 1
fi

# Ensure AWS credentials are available
echo "Verifying AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS credentials not found or not valid. Please configure AWS CLI."
    exit 1
fi

# Create S3 bucket for Terraform state if it doesn't exist
echo "Creating S3 bucket for Terraform state if it doesn't exist..."
if ! aws s3api head-bucket --bucket "$TF_STATE_BUCKET" 2>/dev/null; then
    echo "Creating S3 bucket: $TF_STATE_BUCKET in region $AWS_REGION"
    if [ "$AWS_REGION" = "us-east-1" ]; then # Caveat for us-east-1
        aws s3api create-bucket \
            --bucket "$TF_STATE_BUCKET" \
            --region "$AWS_REGION" \
            --no-cli-pager
    else
        aws s3api create-bucket \
            --bucket "$TF_STATE_BUCKET" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION" \
            --no-cli-pager
    fi

    # Enable versioning
    echo "Enabling versioning on S3 bucket..."
    aws s3api put-bucket-versioning \
        --bucket "$TF_STATE_BUCKET" \
        --versioning-configuration Status=Enabled

    # Enable server-side encryption
    echo "Enabling server-side encryption on S3 bucket..."
    aws s3api put-bucket-encryption \
        --bucket "$TF_STATE_BUCKET" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'

    # Block public access
    echo "Blocking public access to S3 bucket..."
    aws s3api put-public-access-block \
        --bucket "$TF_STATE_BUCKET" \
        --public-access-block-configuration '{
            "BlockPublicAcls": true,
            "IgnorePublicAcls": true,
            "BlockPublicPolicy": true,
            "RestrictPublicBuckets": true
        }'
else
    echo "S3 bucket already exists: $TF_STATE_BUCKET"
fi

# Generate backend configuration
echo "Generating Terraform backend configuration..."
cat > backend.tf << EOF
terraform {
  backend "s3" {
    bucket         = "${TF_STATE_BUCKET}"
    key            = "${ENVIRONMENT}/terraform.tfstate"
    region         = "${AWS_REGION}"
    encrypt        = true
    use_lockfile   = true  # Use S3 native state locking
  }
}
EOF

echo ""
echo "==============================================="
echo "Bootstrap complete! Backend configuration has been written to backend.tf"
echo "This configures Terraform to use the '${ENVIRONMENT}' environment state path."
echo "Copy this file to your Terraform project directory:"
echo "  cp backend.tf infrastructure/terraform/environments/${ENVIRONMENT}/"
echo "==============================================="

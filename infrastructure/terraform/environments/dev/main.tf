provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket       = var.tf_state_bucket
    key          = "dev/terraform.tfstate"
    region       = var.region
    encrypt      = true
    use_lockfile = true
  }
}

module "foundation" {
  source = "../../modules/foundation"

  region       = var.region
  cluster_name = var.cluster_name
  environment  = "dev"
  project_name = var.project_name

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
}

module "eks" {
  source = "../../modules/eks"

  # Only create EKS cluster after VPC and networking are ready
  depends_on = [module.foundation]

  region          = var.region
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  environment     = "dev"
  project_name    = var.project_name

  vpc_id                    = module.foundation.vpc_id
  subnet_ids                = module.foundation.private_subnets
  cluster_security_group_id = module.foundation.cluster_security_group_id
  node_security_group_id    = module.foundation.node_security_group_id

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  node_group_min_size     = var.node_group_min_size
  node_group_max_size     = var.node_group_max_size
  node_group_desired_size = var.node_group_desired_size
  node_instance_types     = var.node_instance_types
  node_key_name           = var.node_key_name

  admin_role_arn     = module.foundation.admin_role_arn
  developer_role_arn = module.foundation.developer_role_arn
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

# Helm provider for installing charts
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

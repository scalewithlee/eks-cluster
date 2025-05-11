locals {
  name = var.cluster_name
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

# Get access to the effective AWS account and IAM context that terraform uses
data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # Use access entries for authentication
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    admin-role = {
      kubernetes_groups = ["system:masters"]
      principal_arn     = var.admin_role_arn
      type              = "STANDARD"
    }
    developer-role = {
      kubernetes_groups = ["developers"]
      principal_arn     = var.developer_role_arn
      type              = "STANDARD"
    }
  }

  cluster_security_group_id = var.cluster_security_group_id

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default = {
      name                       = "${local.name}"
      instance_types             = var.node_instance_types
      min_size                   = var.node_group_min_size
      max_size                   = var.node_group_max_size
      desired_size               = var.node_group_desired_size
      subnet_ids                 = var.subnet_ids
      vpc_security_group_ids     = [var.node_security_group_id]
      ami_type                   = var.ami_type
      enable_bootstrap_user_data = true
      key_name                   = var.node_key_name
    }
  }

  tags = local.tags
}

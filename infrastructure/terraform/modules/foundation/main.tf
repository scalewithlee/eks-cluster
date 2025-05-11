provider "aws" {
  region = var.region
}

# Get access to the effective AWS account and IAM context that terraform uses
data "aws_caller_identity" "current" {}

locals {
  name = var.cluster_name
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = var.project_name
  }
}

module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  version         = "~> 5.0"
  name            = local.name
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # EKS-specific tags
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb"     = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/elb"              = 1
  }

  enable_nat_gateway     = true # Enable outbound traffic from private subnets
  single_nat_gateway     = true # Use the same NAT gateway for all private subnets
  one_nat_gateway_per_az = false
  enable_vpn_gateway     = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  tags = local.tags
}

# Cluster security group
resource "aws_security_group" "cluster_sg" {
  name        = "${local.name}-cluster-sg"
  description = "Security group for the EKS cluster control plane"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name = "${local.name}-cluster-sg"
    }
  )
}

resource "aws_security_group_rule" "cluster_ingress_https" {
  description       = "Allow inbound HTTPS traffic"
  security_group_id = aws_security_group.cluster_sg.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "cluster_egress_all" {
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.cluster_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Security group for the worker nodes
resource "aws_security_group" "node_sg" {
  name        = "${local.name}-node-sg"
  description = "Security group for the EKS nodes"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    local.tags,
    {
      Name                                  = "${local.name}-node-sg"
      "kubernetes.io/cluster/${local.name}" = "owned"
    }
  )
}

resource "aws_security_group_rule" "node_ingress_self" {
  description              = "Allow nodes to communicate with each other"
  security_group_id        = aws_security_group.node_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node_sg.id
}

resource "aws_security_group_rule" "node_egress_all" {
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.node_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "cluster_ingress_node" {
  description              = "Allow cluster control plane to talk to worker nodes"
  security_group_id        = aws_security_group.cluster_sg.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.node_sg.id
}

# IAM Roles for Kubernetes access
resource "aws_iam_role" "admin_role" {
  name = "${local.name}-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "admin_eks_access" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "developer_role" {
  name = "${local.name}-developer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "developer_eks_access" {
  role       = aws_iam_role.developer_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# ECR repository for container images
resource "aws_ecr_repository" "app_images" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = local.tags
}

# ECR policy to allow EKS nodes to pull the images
resource "aws_ecr_repository_policy" "app_images_policy" {
  repository = aws_ecr_repository.app_images.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# ECR lifecycle policy
resource "aws_ecr_lifecycle_policy" "app_images_lifecycle" {
  repository = aws_ecr_repository.app_images.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

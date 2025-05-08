provider "aws" {
  region = var.region
}

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

  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = !var.single_nat_gateway
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

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}

variable "environment" {
  description = "Environment to deploy to"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets within the VPC"
  type        = list(string)
}

variable "ami_type" {
  description = "The type of AMI the EKS nodes will use"
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_security_group_id" {
  description = "ID of the security group for the EKS nodes"
  type        = string
}

variable "cluster_security_group_id" {
  description = "ID of the security group for the EKS cluster"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Whether or not to enable public API endpoints for the cluster"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Whether or not to enable private API endpoints for the cluster"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_group_min_size" {
  description = "The minimum number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "The maximum number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "The desired number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "node_instance_types" {
  description = "List of instance types for the node group(s)"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_key_name" {
  description = "The name of an EC2 SSH key pair to access the nodes"
  type        = string
  default     = null
}

variable "admin_role_arn" {
  description = "The IAM Role ARN for the cluster admin"
  type        = string
}

variable "developer_role_arn" {
  description = "The IAM Role ARN for the cluster developer"
  type        = string
}

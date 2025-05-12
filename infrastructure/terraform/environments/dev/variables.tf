variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.32"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
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

variable "node_group_min_size" {
  description = "Minimum number of nodes in the EKS managed node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the EKS managed node group"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the EKS managed node group"
  type        = number
  default     = 1
}

variable "node_instance_types" {
  description = "List of instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_key_name" {
  description = "The name of an EC2 key pair that can be used to SSH into the nodes"
  type        = string
  default     = null # Disable direct SSH access
}

variable "applications" {
  description = "A list of applications that will be pushed to ECR"
  type        = list(string)
  default     = ["hash-service"]
}

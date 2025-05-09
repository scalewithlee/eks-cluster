variable "node_security_group_id" {
  description = "ID of the security group for the EKS nodes"
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

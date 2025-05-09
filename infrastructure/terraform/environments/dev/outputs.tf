output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS control plane API"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "kubeconfig_command" {
  description = "Command to configure kubectl to connect to the cluster"
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_id}"
}

output "access_entries" {
  description = "Map of access entries created for the cluster"
  value       = module.eks.access_entries
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.foundation.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.foundation.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.foundation.public_subnets
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.foundation.nat_public_ips
}

output "admin_role_arn" {
  description = "ARN of the admin role for EKS access"
  value       = module.foundation.admin_role_arn
}

output "developer_role_arn" {
  description = "ARN of the developer role for EKS access"
  value       = module.foundation.developer_role_arn
}

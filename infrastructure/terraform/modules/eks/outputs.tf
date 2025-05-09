output "cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "The EKS cluster's ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "The endpoint of the EKS control place API"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "The security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role" {
  description = "IAM Role name of the EKS cluster (AWS is handling this)"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "The ARN of the cluster's IAM Role"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  description = "The URL of the EKS cluster for the open identity connect provider"
  value       = module.eks.cluster_oidc_issuer_url
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "eks_managed_node_groups" {
  description = "Map of EKS managed node groups"
  value       = module.eks.eks_managed_node_groups
}

output "access_entries" {
  description = "Map of access entries created for the cluster"
  value       = module.eks.access_entries
}

output "kubeconfig" {
  description = "kubectl configuration to connect to the cluster"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "cluster_security_group_id" {
  description = "The ID of the security group for the EKS cluster"
  value       = aws_security_group.cluster_sg.id
}

output "node_security_group_id" {
  description = "The ID of the security group for the cluster nodes"
  value       = aws_security_group.node_sg.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "nat_public_ips" {
  description = "The public IPs of the NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "availability_zones" {
  description = "List of AZs used"
  value       = var.availability_zones
}

output "admin_role_arn" {
  description = "The IAM Role ARN for the cluster admin role"
  value       = aws_iam_role.admin_role.arn
}

output "developer_role_arn" {
  description = "The IAM Role ARN for the cluster developer role"
  value       = aws_iam_role.developer_role.arn
}

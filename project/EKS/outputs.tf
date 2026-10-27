output "eks_cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS Cluster Name"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS Cluster API Endpoint"
}

output "eks_node_group_name" {
  value       = aws_eks_node_group.private_nodes.node_group_name
  description = "EKS Node Group Name"
}

output "eks_node_security_group" {
  value       = aws_security_group.node_sg.id
  description = "EKS Worker Node Security Group ID"
}


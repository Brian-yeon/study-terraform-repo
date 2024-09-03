output "cluster_endpoint" {
  value       = aws_eks_cluster.private-eks.endpoint
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.private-eks.certificate_authority[0].data
}


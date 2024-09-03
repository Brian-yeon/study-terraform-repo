# EKS node-group
resource "aws_eks_node_group" "private-eks-node-group" {
  cluster_name    = "private-eks"
  node_group_name = "${var.CLUSTER_NAME}-node-group"
  node_role_arn   = aws_iam_role.eks-node-group-role.arn
  subnet_ids      = var.EKS_SUBNET_ID

  instance_types = [var.INSTANCE_TYPE]
  
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  
  remote_access {
    ec2_ssh_key = var.NODE_KEY_PAIR
    source_security_group_ids = [var.BASTION_SG_ID]
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.eks-node-group-role-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-group-role-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-group-role-AmazonEC2ContainerRegistryReadOnly
  ]
}
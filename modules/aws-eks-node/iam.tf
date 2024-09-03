# IAM role for EKS node-group
resource "aws_iam_role" "eks-node-group-role" {
  name = "${var.CLUSTER_NAME}-node-group-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM Role & Policy Attachment for node-group (AmazonEKSWorkerNodePolicy)
resource "aws_iam_role_policy_attachment" "eks-node-group-role-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group-role.name
}

# IAM Role & Policy Attachment for node-group (AmazonEC2ContainerRegistryReadOnly)
resource "aws_iam_role_policy_attachment" "eks-node-group-role-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group-role.name
}

# IAM Role & Policy Attachment for node-group (AmazonEKS_CNI_Policy)
resource "aws_iam_role_policy_attachment" "eks-node-group-role-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group-role.name
}

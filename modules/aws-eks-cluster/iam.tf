# IAM role for EKS cluster
resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.CLUSTER_NAME}-cluster-role"
  # "Service": "eks.amazonaws.com"  -> IAM Role 생성 시, eks Profile 역할로 사용됨을 지정
  # "Action": "sts:AssumeRole" -> 특정 Role(Role에 결부된 권한)을 임시로 인수(Assume)
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# IAM Role & Policy Attachment for EKS cluster (AmazonEKSClusterPolicy)
resource "aws_iam_role_policy_attachment" "eks-cluster-role-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

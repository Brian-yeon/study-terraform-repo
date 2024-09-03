################################################################################
# Data Source of route tables
################################################################################

# Data sources of public route tables
data "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.eks-vpc.id

  filter {
    name = "tag:Name"
    values = ["public*"]
  }

  depends_on = [aws_route_table.public-subnet-rtb]
}

# Data sources of private route tables
data "aws_route_table" "private-rtb" {
  count = length(aws_subnet.eks-private-subnet)
  vpc_id = aws_vpc.eks-vpc.id

  filter {
    name = "tag:Name"
    values = ["private*${count.index}*"]
  }

  depends_on = [aws_route_table.private-subnet-rtb]
}

################################################################################
# Data Source of subnet ids
################################################################################

# Data sources of public subnet ids
data "aws_subnets" "public_subnet_ids" {
  filter {
    name = "tag:Name"
    values = ["*public*"]
  }
  depends_on = [aws_subnet.eks-public-subnet]
}

# Data sources of private subnet ids
data "aws_subnets" "private_subnet_ids" {
  filter {
    name = "tag:Name"
    values = ["*private*"]
  }
  depends_on = [aws_subnet.eks-private-subnet]
}

################################################################################
# Setting data sources of subnet ids as a local variable
################################################################################

# Setting data sources of public subnet ids as a local variable
locals {
  public_subnet_id = tolist(data.aws_subnets.public_subnet_ids.ids)
}

# Setting data sources of private subnet ids as a local variable
locals {
  private_subnet_id = tolist(data.aws_subnets.private_subnet_ids.ids)
}
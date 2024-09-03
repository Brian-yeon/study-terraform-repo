# VPC
resource "aws_vpc" "eks-vpc" {
  cidr_block = var.VPC_CIDR_BLOCK
  enable_dns_hostnames = false

  tags = {
    Name = "${var.VPC_NAME}"
  } 
}

# Public Subnets
# each.key => subnet.name, each.vaule => each subnet object
resource "aws_subnet" "eks-public-subnet" {
  for_each             = { for subnet in var.PUBLIC_SUBNET : subnet.name => subnet }

  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = each.value.subnet_cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip
  tags = {
    Name = each.key
    "kubernetes.io/cluster/${var.CLUSTER_NAME}" = "shared"
    "kubernetes.io/role/elb"  = "1"
  }
}

# Private Subnets
resource "aws_subnet" "eks-private-subnet" {
  for_each             = { for subnet in var.PRIVATE_SUBNET : subnet.name => subnet }

  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = each.value.subnet_cidr
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip
  tags = {
    Name                             = each.key
    "kubernetes.io/cluster/${var.CLUSTER_NAME}" = "shared"
    "kubernetes.io/role/internal-elb"  = "1"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "private-eks-igw" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "${var.VPC_NAME}-igw"
  }
}

# EIP for NAT Gateway
resource "aws_eip" "eks-eip" {
  count = length(aws_subnet.eks-private-subnet)
  tags = {
    Name = "${var.VPC_NAME}-eip-${count.index}-${var.AWS_REGION}"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "eks-nat" {
  count         = length(aws_subnet.eks-private-subnet)
  allocation_id = aws_eip.eks-eip[count.index].id
  subnet_id     = local.public_subnet_id[count.index]

  tags = {
    Name = "${var.VPC_NAME}-nat-${count.index}-${var.AWS_REGION}"
  }

  depends_on = [aws_internet_gateway.private-eks-igw]
}

# Route table to map to private subnet
resource "aws_route_table" "private-subnet-rtb" {
  count  = length(aws_subnet.eks-private-subnet)
  
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks-nat[count.index].id
  }

  tags = {
    Name = "private-subnet-rtb-${count.index}-${var.AWS_REGION}"
  }
}

# Route table to map to public subnet
resource "aws_route_table" "public-subnet-rtb" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.private-eks-igw.id
  }

  tags = {
    Name = "public-subnet-rtb-${var.AWS_REGION}"
  }
}

# Private subnet and Route table association
resource "aws_route_table_association" "private-subnet-rtb-assoc" {
  count = length(aws_subnet.eks-private-subnet)

  subnet_id      = local.private_subnet_id[count.index]
  route_table_id = data.aws_route_table.private-rtb[count.index].id
}

# Public subnet and Route table association
resource "aws_route_table_association" "public-subnet-rtb-assoc-0" {
  count = length(aws_subnet.eks-public-subnet)

  subnet_id      = local.public_subnet_id[count.index]
  route_table_id = data.aws_route_table.public-rtb.id
}

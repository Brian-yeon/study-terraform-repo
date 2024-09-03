
# Getting my local IP to allow ssh in the security group
data "http" "local_host_ip" {
  url = "http://ipv4.icanhazip.com"
}

# Data sources of key pair
data "aws_key_pair" "key-seoul" {
  key_name           = "key-seoul"
}

# Data sources of public subnet ids
data "aws_subnets" "public_subnet_ids" {
  filter {
    name = "tag:Name"
    values = ["*public*"]
  }
  depends_on = [module.eks-vpc-subnet.eks-public-subnet]
}

# Data sources of private subnet ids
data "aws_subnets" "private_subnet_ids" {
  filter {
    name = "tag:Name"
    values = ["*private*"]
  }
  depends_on = [module.eks-vpc-subnet.eks-private-subnet]
}

# Setting my local IP ids as a local variable
locals {
  local_host_cidr = "${chomp(data.http.local_host_ip.response_body)}/32"
}

# Setting public subnet ids as a local variable
locals {
  public_subnet_id = tolist(data.aws_subnets.public_subnet_ids.ids)
}

# Setting private subnet ids as a local variable
locals {
  private_subnet_id = tolist(data.aws_subnets.private_subnet_ids.ids)
}
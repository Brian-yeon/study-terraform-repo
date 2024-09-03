################################################################################
# VPC module
################################################################################
module "eks-vpc-subnet" {
  source = "./modules/aws-vpc"
  
  AWS_REGION = var.AWS_REGION
  VPC_NAME   = "${var.CLUSTER_NAME}-vpc"
  VPC_CIDR_BLOCK = "10.10.0.0/16"
  CLUSTER_NAME = var.CLUSTER_NAME

  PUBLIC_SUBNET = [
    {
      name              = "eks-subnet-public-ap-northeast-2a"
      subnet_cidr       = "10.10.1.0/24"
      availability_zone = "ap-northeast-2a"
      map_public_ip     = true
    },
    {
      name              = "eks-subnet-public-ap-northeast-2c"
      subnet_cidr       = "10.10.3.0/24"
      availability_zone = "ap-northeast-2c"
      map_public_ip     = true
    }
  ]
  
  PRIVATE_SUBNET = [
    {
      name              = "eks-subnet-private-ap-northeast-2a"
      subnet_cidr       = "10.10.2.0/24"
      availability_zone = "ap-northeast-2a"
      map_public_ip     = false
    },
    {
      name              = "eks-subnet-private-ap-northeast-2c"
      subnet_cidr       = "10.10.4.0/24"
      availability_zone = "ap-northeast-2c"
      map_public_ip     = false
    }
  ]
}

################################################################################
# EC2 module - bastion
################################################################################
module "bastion" {
  source = "./modules/aws-ec2"
  
  EC2_NAME            = "bastion"
  AMI                 = "ami-0e735aba742568824"
  INSTANCE_TYPE       = "t2.micro"
  KEY_PAIR_NAME       = data.aws_key_pair.key-seoul.key_name
  ASSOCIATE_PUBLIC_IP = true
  VPC_ID              = module.eks-vpc-subnet.vpc-id
  SUBNET_ID           = local.public_subnet_id[0]
  LOCAL_HOST_CIDR     = local.local_host_cidr
}

################################################################################
# EC2 module - jenkins-server
################################################################################
module "jenkins-server" {
  source = "./modules/aws-ec2"
  
  EC2_NAME            = "jenkins-server"
  AMI                 = "ami-0e735aba742568824"
  INSTANCE_TYPE       = "t2.micro"
  KEY_PAIR_NAME       = data.aws_key_pair.key-seoul.key_name
  ASSOCIATE_PUBLIC_IP = true
  VPC_ID              = module.eks-vpc-subnet.vpc-id
  SUBNET_ID           = local.public_subnet_id[1]
  LOCAL_HOST_CIDR     = local.local_host_cidr
}

################################################################################
# eks-cluster module
################################################################################
module "eks-cluster" {
  source = "./modules/aws-eks-cluster"
  
  CLUSTER_NAME       = var.CLUSTER_NAME
  PRIVATE_ACCESS     = true
  PUBLIC_ACCESS      = false
  EKS_SUBNET_ID      = local.private_subnet_id[*]
  BASTION_SG_ID      = module.bastion.bastion-sg-id

  depends_on = [module.eks-vpc-subnet]
}

################################################################################
# eks-node module
################################################################################
module "eks-node" {
  source = "./modules/aws-eks-node"

  CLUSTER_NAME       = var.CLUSTER_NAME
  EKS_SUBNET_ID      = local.private_subnet_id[*]
  INSTANCE_TYPE      = "t2.medium"
  NODE_KEY_PAIR      = data.aws_key_pair.key-seoul.key_name
  BASTION_SG_ID      = module.bastion.bastion-sg-id

  depends_on = [module.eks-cluster, module.eks-vpc-subnet]
}

################################################################################
# ecr module
################################################################################
module "ecr" {
  source = "./modules/aws-ecr"

  ECR_NAME           = "ecr"
}
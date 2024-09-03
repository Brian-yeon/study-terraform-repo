resource "aws_ecr_repository" "ecr" {
  name = var.ECR_NAME
  image_tag_mutability = "IMMUTABLE" 
}
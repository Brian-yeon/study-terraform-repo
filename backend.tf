# Please input a value for the variable below
terraform {
  backend "s3" {
    bucket         = ""
    key            = "terraform/terraform.state"
    region         = "ap-northeast-2"
    dynamodb_table = ""
    encrypt        = true
  }
}
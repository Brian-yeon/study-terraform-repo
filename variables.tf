variable "AWS_ACCESS_KEY_ID" {
  description = "Your AWS Access Key ID"
  type        = string
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "Your AWS Secret Key"
  type        = string
}

variable "AWS_REGION" {
  type        = string
  description = "Target AWS region"
}

variable "CLUSTER_NAME" {
  type        = string
  description = "Cluster Name"
}

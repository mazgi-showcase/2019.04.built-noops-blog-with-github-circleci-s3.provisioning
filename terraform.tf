# --------------------------------
# Terraform configuration

terraform {
  required_version = "= 0.11.8"

  backend "s3" {
    bucket = "example-engineers-blog-aws-terraform"
    key    = "example-engineers-blog-aws/terraform"
    region = "us-east-1"
  }
}

provider "aws" {
  version    = "= 1.38.0"
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "us-east-1"
}

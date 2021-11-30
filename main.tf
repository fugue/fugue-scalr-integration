provider "aws" {
  region = "us-east-1"
}

module "s3" {
  source = "./s3"
}
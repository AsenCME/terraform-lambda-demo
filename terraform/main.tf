terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.21.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "apfie-configurations"
    key    = "terraform/lambdas/terraform-lambda-demo.tfstate"
    region = "eu-central-1"
    profile = "default"
  }
}

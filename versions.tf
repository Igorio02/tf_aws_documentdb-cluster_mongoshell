terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.0.0"
    }
  }
  required_version = ">= 0.12.26"
}

provider "aws" {
  region = "us-east-1"
}

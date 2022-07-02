terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.1.1"
}

provider "aws" {
  region  = "us-west-2"
  profile = var.profile_name
}

data "aws_caller_identity" "current" {}

locals {
  pref = "tf-iam-example"
}




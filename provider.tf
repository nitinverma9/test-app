terraform {
  required_version = "1.4.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
    random = {
      source = "random"
      version = "3.5.1"
    }
  }
}

provider "aws" {
  region  = "eu-west-2"
}

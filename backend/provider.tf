provider "aws" {
  region = var.region
}

variable "region" {
    default = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 4.0"
    }
  }
}

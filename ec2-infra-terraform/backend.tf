terraform {
  backend "s3" {
    bucket         = "nginx-ansible-terraform"
    region         = "us-east-2"
    dynamodb_table = "nginx-ansible-terraform"
    key            = "ec2-terraform.tfstate"
  }
}
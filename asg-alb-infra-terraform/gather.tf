data "aws_caller_identity" "current" {}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2",
    ]
  }
}

data "aws_s3_bucket" "playbook_bucket" {
  bucket = "nginx-tf-ansible-playbook"
}

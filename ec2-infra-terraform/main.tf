#########################  VPC with 3 Private, Public and DB (Private) subnets ##############################
#############################################################################################################

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "nginx-ansible-terraform"
  cidr = "10.10.0.0/16"

  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets      = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets       = ["10.10.11.0/24", "10.10.12.0/24", "10.10.13.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

############################## Create a Key Pair #########################################

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "ec2_private_key" {
    content     =  aws_key_pair.ec2_key_pair.public_key
    filename    = "ec2_key.pem"
}

################################# EC2 Instance Creation with Userdata ######################
#######################################################################################################################

module "ec2_userdata" {
  source      = "./modules/terraform-aws-ec2-userdata"
}

resource "aws_instance" "ec2_instance" {
  ami                         = data.aws_ami.ami.id
  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ec2_key_pair.key_name
  vpc_security_group_ids      = [module.ec2_security_group.security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_iam_profile.id
  user_data                   = module.ec2_userdata.userdata
  tags = {
    "Name" = "Nginx-EC2"
  }
}

resource "local_file" "ec2-dns" {
    content     =  aws_instance.ec2_instance.public_dns 
    filename    = "inventory.txt"
}

resource "null_resource" "execute_ansible" {
 
  depends_on = [aws_instance.ec2_instance]

  provisioner "local-exec" {
   command =  <<EOT
      export ANSIBLE_HOST_KEY_CHECKING=False, 
      ansible ${aws_instance.ec2_instance.public_dns} --private-key=ec2_key.pem -m ping -i inventory.txt
    EOT
  }
}
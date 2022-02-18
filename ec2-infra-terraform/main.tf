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
   command = [
     "export ANSIBLE_HOST_KEY_CHECKING=False", 
     "ansible ${aws_instance.ec2_instance.public_dns} -m ping -i inventory.txt"
   ]
  }
}
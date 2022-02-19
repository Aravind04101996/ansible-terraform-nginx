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
#########################################################################################

resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

######################### Store Private Key in a file locally #############################
#########################################################################################

resource "local_file" "ec2_private_key" {
    sensitive_content     =  tls_private_key.key_pair.private_key_pem
    filename              =  "ec2.pem"
    file_permission       = "0600"
}

################################# EC2 Instance Creation with Userdata ################################
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

##### Create a Cloud Watch Log Group - to store docker container logs ################
#########################################################################################

resource "aws_cloudwatch_log_group" "ec2_cwlogs" {
  name              = "ec2-nginx-cwlogs"
  retention_in_days = 7
}

############## Create an Ansbible inventory file to store EC2 DNS information #################
#########################################################################################
resource "local_file" "ec2-dns" {
    content     =  aws_instance.ec2_instance.public_dns 
    filename    = "inventory.txt"
}

#################### Execute Ansible Playbook on Target Hosts (EC2) #####################
#########################################################################################

resource "null_resource" "execute_ansible_target" {
 
  depends_on = [aws_instance.ec2_instance, local_file.ec2-dns, aws_cloudwatch_log_group.ec2_cwlogs]

  provisioner "local-exec" {
   command =  <<EOT
      sleep 180s
      export ANSIBLE_HOST_KEY_CHECKING=False, 
      ansible ${aws_instance.ec2_instance.public_dns} -u ec2-user --private-key ${local_file.ec2_private_key.filename} -m ping -i inventory.txt,
      ansible-playbook ../ansible-nginx-playbook/webserver_playbook.yml -u ec2-user --private-key ${local_file.ec2_private_key.filename} -i inventory.txt 
    EOT
  }
}
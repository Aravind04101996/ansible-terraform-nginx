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

###################### Create a Cloud Watch Log Group - to store docker container logs #######################
##############################################################################################################

resource "aws_cloudwatch_log_group" "ec2_cwlogs" {
  name              = "ec2-nginx-cwlogs"
  retention_in_days = 7
}


################################ Create an Auto Scaling Group with Userdata ##################################
##############################################################################################################

module "ec2_userdata" {
  source    = "./modules/terraform-aws-ec2-userdata"
  s3_bucket = data.aws_s3_bucket.playbook_bucket.id
  playbook  = "ansible-nginx-playbook.zip"
  vars_file = "webserver_playbook_variables.yml"
}


module "nginx_asg" {
  source                    = "terraform-aws-modules/autoscaling/aws"
  version                   = "5.1.1"
  name                      = "Nginx-EC2-ASG"
  instance_name             = "Nginx-EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 3
  target_group_arns         = []
  health_check_type         = "EC2"
  health_check_grace_period = 420
  tags = {
    "Name" = "Nginx-EC2"
  }
  iam_instance_profile_name = aws_iam_instance_profile.ec2_iam_profile.id
  image_id                  = data.aws_ami.ami.id
  instance_type             = "t2.micro"
  user_data_base64          = module.ec2_userdata.userdata
  security_groups           = [module.ec2_security_group.security_group_id]
  launch_template_name      = "Nginx-EC2"

  depends_on = [aws_cloudwatch_log_group.ec2_cwlogs]
}

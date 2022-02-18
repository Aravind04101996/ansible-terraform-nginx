#################################### EC2 security group with SSH inbound ###################################
#####################################################################################################################

module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name   = "ec2-sg"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]
}
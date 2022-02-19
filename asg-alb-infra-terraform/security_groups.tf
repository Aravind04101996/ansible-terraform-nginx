#################################### ALB & EC2 Security Groups  ####################################################
#####################################################################################################################

module "alb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4"

  name   = "alb-http-sg"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}

module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name   = "asg-sg"
  vpc_id = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_http_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1
  egress_rules                                             = ["all-all"]
}
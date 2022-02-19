################################# IAM Role for EC2 with Required Permissions ################################
#############################################################################################################

resource "aws_iam_role" "ec2_role" {
  name               = "ec2-iam-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {
  name = "ec2-iam-role-profile"
  role = aws_iam_role.ec2_role.name
}

############################ IAM Policy - Session Manager Access ###########################################
#############################################################################################################

resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################ IAM Policy - CW Policy #########################################################
#############################################################################################################


resource "aws_iam_role_policy_attachment" "ec2_cw_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

############################ IAM Policy to pull playbook from S3 Bucket #####################################
#############################################################################################################

resource "aws_iam_role_policy" "get_s3_object" {
  name_prefix = "ec2_get_s3_object"
  role        = aws_iam_role.ec2_role.name
  policy      = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": "arn:aws:s3:::${data.aws_s3_bucket.playbook_bucket.id}/*"
        }
    ]
  }
  EOF
}
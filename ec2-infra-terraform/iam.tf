################################# IAM Role for EC2 with Required Permissions #######################
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


resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {
  name = "ec2-iam-profile"
  role = aws_iam_role.ec2_role.name
}
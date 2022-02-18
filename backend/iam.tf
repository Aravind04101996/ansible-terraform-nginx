data "aws_caller_identity" "current" {}

# IAM Identity provider creation - for Github Actions
resource "aws_iam_openid_connect_provider" "github-oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# OIDC Assume Role Policy
data "aws_iam_policy_document" "oidc-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
       type        = "Federated"
      identifiers   = [aws_iam_openid_connect_provider.github-oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.github-oidc.url}:aud"
      values   = "${aws_iam_openid_connect_provider.github-oidc.client_id_list}"
    }
  }
}

# Creation of IAM Role : github ci cd will assume this role using OIDC
resource "aws_iam_role" "github-oidc-assume-role" {
  name               = "github-oidc-assume-iam-role"
  assume_role_policy = data.aws_iam_policy_document.oidc-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "github-oidc-assume-role-policy" {
  role       = aws_iam_role.github-oidc-assume-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
######################################## S3 bucket for terraform state ###################################################
##########################################################################################################################

resource "aws_s3_bucket" "backend" {
  bucket        = "nginx-ansible-terraform"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 10
    }
  }

  tags = {
    Name = "nginx-ansible-terraform"
  }
}

############################################# State locking in Dynamo DB table ############################################
###########################################################################################################################

resource "aws_dynamodb_table" "state_lock" {
  name         = "nginx-ansible-terraform"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "nginx-ansible-terraform"
  }
}
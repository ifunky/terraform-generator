data "aws_subnet" "private_1b" {
  filter {
    name   = "tag:Name"
    values = ["VPC-private-${var.region}b"]
  }
}

data "aws_subnet" "public_1b" {
  filter {
    name   = "tag:Name"
    values = ["VPC-public-${var.region}b"]  
  }
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
data "aws_vpc" "main" {
    filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet" "private_1a" {
  filter {
    name   = "tag:Name"
    values = ["VPC-private-${var.region}a"]
  }
}

data "aws_subnet" "public_1a" {
  filter {
    name   = "tag:Name"
    values = ["VPC-public-${var.region}a"]  
  }
}

data "aws_ami" "windows_web" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-20*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] 
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
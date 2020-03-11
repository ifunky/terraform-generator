provider "aws" {
    region              = var.region
    allowed_account_ids = var.aws_account_id
    assume_role {
      role_arn          = var.role_arn
      session_name      = "terraform"
    }     
}

module "backend" {
  source         = "git::https://github.com/ifunky/terraform-aws-backend.git?ref=master"
  bucket_name    = "${var.state_bucket_name}"
  namespace      = "${var.company_name}"
  environment    = "${var.environment_name}"
}

module "account" {
  source = "git::https://github.com/ifunky/terraform-aws-baseline-account.git?ref=master"

  audit_s3_access_bucket_name  = "${var.s3_access_bucket_name}"
  security_account_id          = "${var.security_account_id}"

  tags = {
    Terraform = "true"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_cidr}"

  azs             = "${var.vpc_availability_zones}"
  private_subnets = "${var.vpc_private_subnets}"
  public_subnets  = "${var.vpc_public_subnets}"

  enable_nat_gateway = "${var.vpc_enable_nat_gateway}"
  single_nat_gateway = "${var.vpc_single_nat_gateway}"
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
  }
}

module "cis-baseline" {
  source                          = "git::https://github.com/ifunky/terraform-aws-baseline-cis.git?ref=master"

  vpc_log_retention_in_days       = 90
  vpc_id                          = "${module.vpc.vpc_id}"

  region                          = "${var.region}"
  cloudtrail_name                 = "${var.cloudtrail_name}"
  cloudtrail_multi_region         = true
  cloudtrail_logging              = true
  cloudtrail_log_file_validation  = true
  cloudtrail_log_group_name       = "${var.cloudtrail_log_group_name}"
  cloudtrail_sns_topic            = "${var.cloudtrail_sns_topic}"
  cloudtrail_bucket_name          = "${var.cloudtrail_bucket_name}"

  s3_logging_bucket_name          = "${var.s3_access_bucket_name}"

  tags = {
    Terraform = "true"
  }
}


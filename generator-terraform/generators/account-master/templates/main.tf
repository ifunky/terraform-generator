provider "aws" {
    region              = var.region
    allowed_account_ids = var.aws_account_id
    assume_role {
      role_arn          = var.terraform_role_arn
      session_name      = "terraform"
    }     
}

locals {
  network_acls = {
    default_inbound = [
      {
        rule_no = 100
        action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      },
    ]
    default_outbound = [
      {
        rule_no = 100
        action = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      },
    ]
  } 
}

data "aws_iam_role" "terraform" {
  name = module.account.iam_terraform-role.name
}

locals {
  shared_account_id       = aws_organizations_account.shared.id
  shared_account_role_arn = "arn:aws:iam::${local.shared_account_id}:role/ServiceAccounts/terraform"
}

module "backend" {
  source               = "git::https://github.com/ifunky/terraform-aws-backend.git?ref=master"
  bucket_name          = var.state_bucket_name
  namespace            = var.company
  environment          = var.environment
  write_access_arns    = [var.terraform_role_arn]
  readonly_access_arns = [local.shared_account_role_arn]
}

module "account" {
  source = "git::https://github.com/ifunky/terraform-aws-baseline-account.git?ref=master"

  audit_access_logs_create = true
  namespace                = var.company
  environment              = var.environment
  delimiter                = var.delimiter
  kms_terraform_principles = var.kms_terraform_principles
  security_account_id      = var.security_account_id

  tags = {
    Terraform = "true"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_availability_zones
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway
  enable_vpn_gateway = false

  manage_default_network_acl = true
  default_network_acl_ingress = local.network_acls["default_inbound"]
  default_network_acl_egress = local.network_acls["default_outbound"]
  
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

}

module "cis-baseline" {
  source                          = "git::https://github.com/ifunky/terraform-aws-baseline-cis.git?ref=master"

  vpc_log_retention_in_days       = 90
  vpc_id                          = module.vpc.vpc_id

  region                          = var.region
  cloudtrail_name                 = var.cloudtrail_name
  cloudtrail_multi_region         = true
  cloudtrail_logging              = true
  cloudtrail_log_file_validation  = true
  cloudtrail_log_group_name       = var.cloudtrail_log_group_name
  cloudtrail_sns_topic            = var.cloudtrail_sns_topic
  cloudtrail_bucket_name          = var.cloudtrail_bucket_name

  s3_logging_bucket_name          = module.account.s3_auditaccess_bucket_id

  tags = {
    Terraform = "true"
  }
}

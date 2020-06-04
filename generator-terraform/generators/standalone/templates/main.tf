provider "aws" {
    region              = var.region
    allowed_account_ids = var.aws_account_id
    assume_role {
      role_arn          = var.role_arn
      session_name      = "terraform"
    }     
}

locals {
  network_acls = {
    public_inbound = [
      {
        rule_number = 100
        rule_action      = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      },
    ]
    public_outbound = [
      {
        rule_number = 100
        rule_action      = "allow"
        from_port   = 0
        to_port     = 0
        protocol    = "tcp"
        cidr_block  = var.vpc_cidr
      },
    ]
    private_inbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = var.vpc_public_subnets_all
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = var.vpc_public_subnets_all
      },      
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = var.vpc_public_subnets_all
      },
      {
        rule_number = 130
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }  
    ]

    private_outbound = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },           
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 1024
        to_port     = 65535
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      }
    ]
  } 
}

module "backend" {
  source               = "git::<%=sourceControlPrefix%>terraform-aws-backend.git?ref=master"
  bucket_name          = var.bucket
  namespace            = var.company
  environment          = var.environment
  write_access_arns    = [var.role_arn]
}

module "account" {
  source = "git::<%=sourceControlPrefix%>terraform-aws-baseline-account.git?ref=master"

  audit_access_logs_create = true
  namespace                = var.company
  environment              = var.environment
  delimiter                = var.delimiter
  kms_terraform_principles = var.kms_terraform_principles
  security_account_id      = var.aws_account_id[0]

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

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_dedicated_network_acl  = true
  public_inbound_acl_rules      = local.network_acls["public_inbound"]
  public_outbound_acl_rules     = local.network_acls["public_outbound"]
  public_subnet_tags            = {
    Tier = "Public"
  }

  private_dedicated_network_acl = true
  private_inbound_acl_rules     = local.network_acls["private_inbound"]
  private_outbound_acl_rules    = local.network_acls["private_outbound"]
  private_subnet_tags            = {
    Tier = "Private"
  }


  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true
}

module "cis-baseline" {
  source                          = "git::<%=sourceControlPrefix%>terraform-aws-baseline-cis.git?ref=master"

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

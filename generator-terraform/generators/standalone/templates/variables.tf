#######################################################################
# Common account settings
#######################################################################
variable "region" {
    description = "Default AWS region"
}

# Varibles for backend partial configuration
variable "bucket" {}
variable "role_arn" {}
variable "key" {}

# Account environment and stage settings
variable "aws_account_id" {
    description = "AWS Account ID"
}

variable "company" {
    description = "Company name of account holder"
}

variable "environment" {
    description = "Environment that this represents"
}

variable "stage" {
    description = "Stage within the environment"
    default     = ""
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "cloudtrail_log_group_name" {
    description = "Cloudwatch log name to create for the VPC CloudTrail"  
}

variable "cloudtrail_sns_topic" {
    description = "SNS name for CloudTrail alarms"
}

variable "cloudtrail_bucket_name" {
    description = "S3 bucket name for the CloudTrails logs (in centralised account)"
}

variable "cloudtrail_name" {
    description = "VPC Cloudtrail name"
}

variable "kms_terraform_principles" {
  type        = list(string)
  description = "List of IAM principles that are authorised to encrypt/decrypt secrets"
  default     = []
}

variable "public_key" {
    type        = string
    description = "EC2 Key pair (public generated key)"
}

variable "vpc_name" {
    description = "Name of the VPC"
}

variable "vpc_cidr" {
    description = "CIDR for the VPC"
}

variable "vpc_availability_zones" {
    description = "VPC availability zones"
    type        = list
}

variable "vpc_private_subnets" {
    description = "List of private subnet IP cidr blocks for each availability zone"
    type        = list
}

variable "vpc_public_subnets" {
    description = "List of public subnet IP cidr blocks for each availability zone"
    type        = list
}

variable "vpc_private_subnets_all" {
    description = "CIDR of all private subnets"
    type        = string
}

variable "vpc_public_subnets_all" {
    description = "CIDR of all public subnets"
    type        = string
}



variable "vpc_enable_nat_gateway" {
    description = "Enable NAT gateway on the VPC"
}

variable "vpc_single_nat_gateway" {
    description = "Only create one NAT gateway, useful for dev environments"
}

variable "tags" {
    description = "List of additional tags to apply to all resources"
    default     = {}
}

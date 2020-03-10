#######################################################################
# Common account settings
#######################################################################
variable "region" {
    description = "Default AWS region"
}

# Account environment and stage settings
variable "aws_account_id" {
    description = "AWS Account ID"
}

variable "security_account_id" {
    description = "ID of the account containing IAM/Roles"
}

variable "company_name" {
    description = "Company name of account holder"
}

variable "environment_name" {
    description = "Environment that this represents"
}

variable "stage_name" {
    description = "Stage within the environment"
    default     = ""
}


variable "terraform_role_arn" {
    description = "Role that will be assumed by the AWS provider to make infrastructure changes"
}

variable "cloudtrail_log_group_name" {
    description = "Cloudwatch log name to create for the VPC CloudTrail"  
}

variable "cloudtrail_sns_topic" {
    description = "SNS name for CloudTrail alarms"
}

variable "cloudtrail_bucket_name" {
    description = "S3 bucket name for the CloudTrails logs"
}

variable "cloudtrail_name" {
    description = "VPC Cloudtrail name"
}

variable "vpc_name" {
    description = "Name of the VPC"
}

variable "vpc_cidr" {
    description = "CIDR for the VPC"
}

variable "vpc_availability_zones" {
    description = "VPC availability zones"
    type        = "list"
}

variable "vpc_private_subnets" {
    description = "List of private subnet IP cidr blocks for each availability zone"
    type        = "list"
}

variable "vpc_public_subnets" {
    description = "List of public subnet IP cidr blocks for each availability zone"
    type        = "list"
}

variable "vpc_enable_nat_gateway" {
    description = "Enable NAT gateway on the VPC"
}

variable "vpc_single_nat_gateway" {
    description = "Only create one NAT gateway, useful for dev environments"
}

variable "state_bucket_name" {
    description = "Terraform state bucket name i.e terraform"
}

variable "s3_access_bucket_name" {
    description = "S3 bucket used to audit S3 access"
}
company                     = "companyname"
environment                 = "Shared"

cloudtrail_log_group_name   = "vpc-cloudtrail-log"
cloudtrail_name             = "vpc-cloudtrail"

security_account_id         = "123456787"
master_account_region       = "eu-west-1"

vpc_enable_nat_gateway      = "true"
vpc_single_nat_gateway      = "true"

vpc_name                    = "VPC"
vpc_cidr                    = "10.3.0.0/22"
vpc_cidr_all_networks       = "10.0.0.0/12"
vpc_availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
vpc_private_subnets         = ["10.3.1.0/26", "10.3.1.64/26", "10.3.1.128/26"]
vpc_public_subnets          = ["10.3.2.0/26", "10.3.2.64/26", "10.3.2.128/26"]
vpc_ad_private_subnets      = ["10.3.3.0/26", "10.3.3.64/26", "10.3.3.128/26"]
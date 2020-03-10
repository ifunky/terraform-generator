aws_account_id          = ["1234567890"]

# Parital backend config
bucket                      = "companyname.shared.dev.terraform"  # Refactor somehow - This is used in the aws provider partial config
key                         = "state/terraform.tfstate"
state_bucket_name           = "terraform"
role_arn                    = "arn:aws:iam::123456789:role/ServiceAccounts/terraform"

region                      = "eu-west-1"                   # NOTE: This is read from the make file
stage             	    = "dev"

# Monitoring and alerting settings
cloudtrail_sns_topic        = "arn:aws:sns:eu-west-1:350544979287:audit-alerts-dev"
slack_info_alerts_hook_url  = "https://hooks.slack.com/services/234234"
slack_high_alerts_hook_url  = "https://hooks.slack.com/services/234234"

terraform_state_readonly_arns = [
                                "arn:aws:iam::1234567890:role/ServiceAccounts/terraform", 
                                "arn:aws:iam::1234567892:role/ServiceAccounts/terraform"
                                ]

kms_terraform_principles = [
        "arn:aws:iam::682858061982:role/ServiceAccounts/terraform",
        "arn:aws:iam::350544979287:role/OrganizationAccountAccessRole"
        ]

public_key                    = "ssh-rsa AAm"

vpc_enable_nat_gateway  = "true"
vpc_single_nat_gateway  = "true"

vpc_name                    = "VPC"
vpc_cidr                    = "10.3.0.0/22"
vpc_cidr_all_networks       = "10.0.0.0/12"
vpc_availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
vpc_private_subnets         = ["10.3.1.0/26", "10.3.1.64/26", "10.3.1.128/26"]
vpc_public_subnets          = ["10.3.2.0/26", "10.3.2.64/26", "10.3.2.128/26"]
vpc_ad_private_subnets      = ["10.3.3.0/26", "10.3.3.64/26", "10.3.3.128/26"]
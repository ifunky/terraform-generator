# Parital backend config
aws_account_id              = ["<%=accountNumber%>"]
bucket                      = "<%=stateBucketName%>"
key                         = "state/terraform.tfstate"
state_bucket_name           = "terraform"
role_arn                    = "<%=roleArn%>"

company                     = "<%=companyName%>"
environment                 = "Organisation"

region                      = "<%=region%>"
cloudtrail_log_group_name   = "vpc-cloudtrail-log"
cloudtrail_sns_topic        = "arn:aws:sns:eu-west-1:123456789:audit-alerts-dev"
cloudtrail_name             = "vpc-cloudtrail"
cloudtrail_bucket_name      = "<%=companyName%>-shared-audit-cloudtrail-logs"

kms_terraform_principles    = [
        "<%=roleArn%>",
        "<%=roleArnTempAdmin%>"
        ]

vpc_name                    = "VPC"
vpc_cidr                    = "10.0.0.0/22"
vpc_availability_zones      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
vpc_private_subnets         = ["10.0.1.0/26", "10.0.1.64/26", "10.0.1.128/26"]
vpc_public_subnets          = ["10.0.2.0/26", "10.0.2.64/26", "10.0.2.128/26"]


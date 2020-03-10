data "terraform_remote_state" "master" {
  backend = "s3"
  config = {
    bucket   = "companyname.organisation.terraform"
    key      = var.key
    region   = var.master_account_region
    role_arn = var.role_arn
  }
}

data "aws_caller_identity" "current" {}
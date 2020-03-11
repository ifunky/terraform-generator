data "aws_caller_identity" "id" {}


# aws fms command doesn't work - rasied ticket

/*module "firewall_management_account" {
  source = "git::https://github.com/ifunky/terraform-aws-cli-resource.git?ref=master"

  role            = var.terraform_role_arn
  cmd             = "aws fms associate-admin-account --admin-account ${data.aws_caller_identity.id.account_id}"
  destroy_cmd     = "aws fms disassociate-admin-account"

  tags = {
    Terraform = "true"
  }
}
*/

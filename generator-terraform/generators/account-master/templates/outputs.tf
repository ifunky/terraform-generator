data "aws_organizations_organization" "default" {}

output "organisation_member_account_ids" {
  description = "List of member account IDs (excluding master) "
  value = data.aws_organizations_organization.default.non_master_accounts[*].id
}

output "organisation_all_account_ids" {
  description = "List of member account IDs (including master) "
  value = data.aws_organizations_organization.default.accounts[*].id
}
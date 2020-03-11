resource "aws_organizations_account" "shared" {
  name                       = "Shared"
  email                      = "shared@ifunky.net"
  #iam_user_access_to_billing = "ALLOW"
  parent_id                  = aws_organizations_organizational_unit.core.id
}
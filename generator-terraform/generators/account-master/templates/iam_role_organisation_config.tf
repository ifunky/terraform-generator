data "aws_iam_policy_document" "assume_role_org_config" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "organization_config" {
  name        = "config-for-organisation"
  description = "Enables AWS Config to query other accounts within the organisation"

  assume_role_policy = data.aws_iam_policy_document.assume_role_org_config.json
}

resource "aws_iam_role_policy_attachment" "organization" {
  role       = aws_iam_role.organization_config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
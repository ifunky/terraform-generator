resource "aws_config_configuration_aggregator" "organization" {

  name = "config-aggregator"

  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.organization_config.arn
  }
}

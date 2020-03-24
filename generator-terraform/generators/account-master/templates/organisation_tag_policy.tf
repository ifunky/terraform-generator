resource "aws_organizations_policy" "tagpolicy" {
  name        = "TagPolicy"
  description = "Organisation tagging policy"
  type        = "TAG_POLICY"

  content = <<CONTENT
{
    "tags": {
        "CostCenter": {
            "tag_key": {
                "@@assign": "Company",
                "@@operators_allowed_for_child_policies": ["@@none"]
            }
        },
        "Project": {
            "tag_key": {
                "@@assign": "Project",
                "@@operators_allowed_for_child_policies": ["@@none"]
            }
        }
    }
}
CONTENT
}

resource "aws_organizations_policy_attachment" "root_tagpolicy" {
  policy_id = aws_organizations_policy.tagpolicy.id
  target_id = aws_organizations_organization.default.roots.0.id
}
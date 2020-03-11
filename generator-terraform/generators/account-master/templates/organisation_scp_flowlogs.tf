resource "aws_organizations_policy" "flowlogs" {
  name = "DenyFlowLogChanges"
  description = "Deny disabling of Flow Logs"

  content = <<CONTENT
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Deny",
    "Action": [
        "ec2:DeleteFlowLogs",
        "logs:DeleteLogGroup",
        "logs:DeleteLogStream"
    ],
    "Resource": "*"
    }
]
}
CONTENT
}


resource "aws_organizations_policy_attachment" "root_flowlogs" {
  policy_id = aws_organizations_policy.flowlogs.id
  target_id = aws_organizations_organization.default.roots.0.id
}
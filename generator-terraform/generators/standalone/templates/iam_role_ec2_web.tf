data "aws_iam_policy_document" "s3_web" {
  statement {

    effect    = "Allow"
    actions   = [ 
      "s3:Get*",
      "s3:List*"
      ]
    resources = ["arn:aws:s3:::*"]
  }
}

resource "aws_iam_instance_profile" "web" {
  name = "web_profile"
  role = aws_iam_role.web.id
}

resource "aws_iam_role" "web" {
  name        = "web_role"
  description = "IAM web instance profile for web apps"
  path        = "/"

  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
}

resource "aws_iam_policy" "s3_web" {
  name        = "web-s3"
  description = "Provides access to S3 buckets"
  policy      = data.aws_iam_policy_document.s3_web.json 
}

resource "aws_iam_role_policy_attachment" "s3_web" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.s3_web.arn
}

resource "aws_iam_role_policy_attachment" "ssm_web_core" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm_web_ec2" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

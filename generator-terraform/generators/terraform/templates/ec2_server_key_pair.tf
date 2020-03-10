module "key_pair_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  namespace  = var.environment
  stage      = var.stage
  delimiter  = "-"
}

resource "aws_key_pair" "server" {
  key_name   = module.key_pair_label.id
  public_key = var.public_key
}
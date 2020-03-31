module "label_web_placement_group" {
  source     = "git::https://github.com/cloudposse/terraform-null-label?ref=master"
  namespace  = var.company
  stage      = var.stage
  attributes = ["web"]
  delimiter  = "-"
}

resource "aws_placement_group" "web" {
  name     = module.label_web_placement_group.id
  strategy = "spread"
}
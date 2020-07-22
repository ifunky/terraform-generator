locals {
  web_security_group_name = "sg_web_"
}

resource "aws_security_group" "web" {
  name        = local.web_security_group_name
  description = "Allow HTTP/S traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name        = local.web_security_group_name
    Environment = var.environment
    Stage       = var.stage
  }
}
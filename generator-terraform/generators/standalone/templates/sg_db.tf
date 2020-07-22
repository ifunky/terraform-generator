locals {
  db_security_group_name = "sg_database"
}

resource "aws_security_group" "db" {
  name        = local.db_security_group_name
  description = "Allow database traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 1433
    to_port     = 1433
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
    Name        = local.db_security_group_name
    Environment = var.environment
    Stage       = var.stage
  }
}
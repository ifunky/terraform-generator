resource "aws_security_group" "windows_mangagement" {
  name        = "sg_windows_management"
  description = "Windows management (RDP/WinRM/Deployment) rules"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
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
    Name = "sg_windows_management"
  }
}
module "ec2_windows" {
  source = "git::https://github.com/ifunky/terraform-aws-ec2-instance?ref=master"

  ami             = data.aws_ami.windows_web.id
  iam_role        = aws_iam_instance_profile.web.name
  key_pair        = aws_key_pair.server.key_name
  instance_type   = "t3a.small"
  vpc_id          = data.aws_vpc.main.id
  security_groups = [aws_security_group.windows_mangagement.id, aws_security_group.web.id]
  subnet          = data.aws_subnet.public_1a.id
  name            = "IFWEB01"
  namespace       = "ifunky"
  stage           = "dev"

  user_data       =<<EOF
      choco install googlechrome -y
      
      # Allow local file copy across RDP
      Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fDisableCdm" -Value 0
      EOF

  tags = {
    Terraform = "true"
  }
}
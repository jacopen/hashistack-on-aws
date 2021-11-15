terraform {
  required_version = ">= 0.12.26"
}

data "aws_region" "current" {
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
resource "aws_instance" "bastion" {
  ami                         = "ami-036d0684fc96830ca"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.main.id
  user_data                   = file("user-data/install-nomad.sh")

  tags = {
    Name = "bastion"
  }
}

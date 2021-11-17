# data source for vanilla Ubuntu AWS AMI as base image for cluster
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "nomad_cluster" {
  source = "./modules/nomad_cluster"

  allowed_inbound_cidrs  = var.allowed_inbound_cidrs
  instance_type          = var.instance_type
  consul_version         = var.consul_version
  nomad_version          = var.nomad_version
  consul_cluster_version = var.consul_cluster_version
  bootstrap              = var.bootstrap
  key_name               = var.key_name
  name_prefix            = var.name_prefix
  vpc_id                 = aws_vpc.main.id
  public_ip              = var.public_ip
  nomad_servers          = var.nomad_servers
  nomad_clients          = var.nomad_clients
  consul_config          = var.consul_config
  enable_connect         = var.enable_connect
  owner                  = var.owner
  ami_id                 = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu.id
  depends_on             = [aws_subnet.main]
}

resource "aws_vpc" "main" {
  cidr_block         = "10.0.0.0/16"
  instance_tenancy   = "default"
  enable_dns_support = true

  tags = {
    Name = "jacopen-nomad"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "jacopen-nomad"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "jacopen-nomad"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id

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
  ami                         = var.ami_id
  instance_type               = "t3.small"
  associate_public_ip_address = true
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  subnet_id                   = aws_subnet.main.id

  tags = {
    Name = "jacopen-bastion"
  }
}

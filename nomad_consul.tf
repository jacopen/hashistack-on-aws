data "aws_ami" "nomad_consul" {
  most_recent = true

  owners = ["562637147889"]

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "is-public"
    values = ["true"]
  }

  filter {
    name   = "name"
    values = ["nomad-consul-ubuntu-*"]
  }
}

module "servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.8.0"

  cluster_name  = "${var.cluster_name}-server"
  cluster_size  = var.num_servers
  instance_type = var.server_instance_type

  cluster_tag_key   = var.cluster_tag_key
  cluster_tag_value = var.cluster_tag_value

  ami_id    = var.ami_id == null ? data.aws_ami.nomad_consul.image_id : var.ami_id
  user_data = data.template_file.user_data_server.rendered

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.main.id]

  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  allowed_inbound_cidr_blocks = ["10.0.0.0/8", "124.36.216.208/32", "172.25.16.0/20"]
  ssh_key_name                = var.ssh_key_name

  associate_public_ip_address = true

  tags = [
    {
      key                 = "Environment"
      value               = "development"
      propagate_at_launch = true
    },
  ]
}

module "nomad_security_group_rules" {
  source = "./modules/nomad-security-group-rules"

  security_group_id = module.servers.security_group_id

  allowed_inbound_cidr_blocks = ["10.0.0.0/8", "124.36.216.208/32", "172.25.16.0/20"]
}

data "template_file" "user_data_server" {
  template = file("${path.module}/user-data/user-data-server.sh")

  vars = {
    cluster_tag_key   = var.cluster_tag_key
    cluster_tag_value = var.cluster_tag_value
    num_servers       = var.num_servers
  }
}

module "clients" {
  source = "./modules/nomad-cluster"

  cluster_name  = "${var.cluster_name}-client"
  instance_type = var.instance_type

  cluster_tag_key   = "nomad-clients"
  cluster_tag_value = var.cluster_name

  min_size = var.num_clients

  max_size         = var.num_clients
  desired_capacity = var.num_clients

  ami_id    = var.ami_id == null ? data.aws_ami.nomad_consul.image_id : var.ami_id
  user_data = data.template_file.user_data_client.rendered

  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.main.id]

  allowed_ssh_cidr_blocks = ["0.0.0.0/0"]

  associate_public_ip_address = true

  allowed_inbound_cidr_blocks = ["10.0.0.0/8", "124.36.216.208/32", "172.25.16.0/20"]
  ssh_key_name                = var.ssh_key_name

  tags = [
    {
      key                 = "Environment"
      value               = "development"
      propagate_at_launch = true
    }
  ]
}

module "consul_iam_policies" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.8.0"

  iam_role_id = module.clients.iam_role_id
}

data "template_file" "user_data_client" {
  template = file("${path.module}/user-data/user-data-client.sh")

  vars = {
    cluster_tag_key   = var.cluster_tag_key
    cluster_tag_value = var.cluster_tag_value
  }
}
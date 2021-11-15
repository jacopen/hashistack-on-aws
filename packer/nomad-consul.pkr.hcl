packer {
  required_version = ">= 0.12.0"
}

variable "ami_name_prefix" {
  type    = string
  default = "nomad-consul"
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

variable "consul_module_version" {
  type    = string
  default = "v0.11.0"
}

variable "consul_version" {
  type    = string
  default = "1.9.11"
}

variable "nomad_version" {
  type    = string
  default = "1.1.6"
}

data "amazon-ami" "amzn2" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "*amzn2-ami-hvm-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = "${var.aws_region}"
}

data "amazon-ami" "bionic" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
}

data "amazon-ami" "focal" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "*ubuntu-focal-20.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
}

source "amazon-ebs" "ubuntu18-ami" {
  ami_description = "An example of how to build an Ubuntu 18.04 AMI that has Nomad and Consul installed"
  ami_name        = "${var.ami_name_prefix}-ubuntu18-${formatdate("DD-MMM-YY-hh-mm", timestamp())}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami      = "${data.amazon-ami.bionic.id}"
  ssh_username    = "ubuntu"
}

source "amazon-ebs" "ubuntu20-ami" {
  ami_description = "An Ubuntu 20.04 AMI that has Nomad, Consul and Docker installed."
  ami_name        = "${var.ami_name_prefix}-docker-ubuntu20-${formatdate("DD-MMM-YY-hh-mm", timestamp())}"
  instance_type   = "t2.micro"
  region          = "${var.aws_region}"
  source_ami      = "${data.amazon-ami.focal.id}"
  ssh_username    = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu18-ami",
    "source.amazon-ebs.ubuntu20-ami"
  ]

  provisioner "shell" {
    inline = ["sudo apt-get install -y git"]
    only   = ["ubuntu20-ami", "ubuntu18-ami"]
  }

  provisioner "shell" {
    inline       = ["mkdir -p /tmp/terraform-aws-nomad"]
    pause_before = "30s"
  }

  provisioner "file" {
    destination = "/tmp/terraform-aws-nomad"
    source      = "${path.root}/../"
  }

  provisioner "shell" {
    environment_vars = ["NOMAD_VERSION=${var.nomad_version}", "CONSUL_VERSION=${var.consul_version}", "CONSUL_MODULE_VERSION=${var.consul_module_version}"]
    script           = "${path.root}/setup_nomad_consul.sh"
  }
}

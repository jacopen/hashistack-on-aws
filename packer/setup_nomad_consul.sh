#!/bin/sh
set -e

/tmp/terraform-aws-nomad/modules/install-nomad/install-nomad --version "${NOMAD_VERSION}"
/tmp/terraform-aws-nomad/modules/install-consul/install-consul --version "${CONSUL_VERSION}"
/tmp/terraform-aws-nomad/modules/setup-systemd-resolved/setup-systemd-resolved

cd /tmp
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz

sudo touch /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables
echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

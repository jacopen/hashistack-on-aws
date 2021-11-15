#!/bin/sh
set -e

SCRIPT=`basename "$0"`

# NOTE: git is required, but it should already be preinstalled on Ubuntu 16.0
#echo "[INFO] [${SCRIPT}] Setup git"
#sudo apt install -y git

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    vim \
    curl \
    jq

# Using Docker CE directly provided by Docker
echo "[INFO] [${SCRIPT}] Setup docker"
cd /tmp/
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
apt-cache policy docker-ce

sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -a -G docker ubuntu

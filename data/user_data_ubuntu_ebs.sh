#!/bin/bash
## Consul setup
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y
apt-get install -y linux-aws unzip

mkdir /data
chown -R ubuntu:ubuntu /data/
mkfs.ext4 /dev/xvdf
mount /dev/xvdf /data

mkdir -p /home/ubuntu/data
ln -s /data /home/ubuntu/data

#!/bin/bash
set -e
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade
apt-get upgrade -y linux-aws
apt-get install -y awscli


# Cloudwatch
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Install docker
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce
usermod -aG docker ubuntu

# Install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Pushed to post ebs mount remote-exec

cat <<EOF >/home/ubuntu/docker-compose.yml
version: '3'
services:
   prep:
      image: 'iconloop/prep-node:1905292100xdd3e5a'
      network_mode: host
      environment:
         LOOPCHAIN_LOG_LEVEL: "SPAM"
         DEFAULT_PATH: "/data/loopchain"
         SERVICE: "jinseong"
         LOG_OUTPUT_TYPE: "file"
         TIMEOUT_FOR_LEADER_COMPLAIN : 120
         MAX_TIMEOUT_FOR_LEADER_COMPLAIN : 600
      volumes:
         - /opt/data:/data
      ports:
         - 9000:9000
         - 7100:7100
EOF
#/usr/local/bin/docker-compose -f /home/ubuntu/docker-compose.yml up -d
#       Logging
#cat<<EOF> /etc/systemd/system/awslogs.service
#[Unit]
#Description=Service for CloudWatch Logs agent
#After=rc-local.service
#
#[Service]
#Type=simple
#Restart=always
#KillMode=process
#TimeoutSec=infinity
#PIDFile=/var/awslogs/state/awslogs.pid
#ExecStart=/var/awslogs/bin/awslogs-agent-launcher.sh --start --background --pidfile $PIDFILE --user awslogs --chuid awslogs &
#
#[Install]
#WantedBy=multi-user.target
#EOF

#systemctl start awslogs.service
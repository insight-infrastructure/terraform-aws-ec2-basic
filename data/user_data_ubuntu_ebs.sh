#!/bin/bash
## Consul setup
apt-get install -y unzip
curl --silent --remote-name https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip
unzip consul_1.6.1_linux_amd64.zip
chown root:root consul
mv consul /usr/local/bin/
useradd --system --home /etc/consul.d --shell /bin/false consul
mkdir --parents /opt/consul
chown --recursive consul:consul /opt/consul
PRIVIP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4/)
tee -a /etc/systemd/system/consul.service << CONSULSVCEND
[Unit]
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul.d/consul.hcl -retry-join="provider=aws tag_key=consul-servers tag_value=auto-join addr_type=private_v4"
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
Restart=on-failure
SyslogIdentifier=consul

[Install]
WantedBy=multi-user.target
CONSULSVCEND

mkdir --parents /etc/consul.d
tee -a /etc/consul.d/consul.hcl << CONSULHCLEND
{
"bind_addr": "$PRIVIP",
"datacenter": "us-east-1",
"data_dir": "/opt/consul",
"server": false
"retry_join": ["provider=aws tag_key=consul-servers tag_value=auto-join addr_type=private_v4"]
}
CONSULHCLEND

chown --recursive consul:consul /etc/consul.d
chmod 640 /etc/consul.d/consul.hcl

systemctl enable consul
systemctl start consul

## Prometheus setup
# Set node exporter version
# Either pin to latest
#NODE_EXPORTER_VERSION='latest'
# Or pin a specific release
# NOTE: "latest" doensn't seem to work :/
NODE_EXPORTER_VERSION='0.18.1'

useradd -m -s /bin/bash prometheus

curl -L -O  https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz

tar -xzvf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64 /home/prometheus/node_exporter
rm node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
chown -R prometheus:prometheus /home/prometheus/node_exporter

# Add node_exporter as systemd service
tee -a /etc/systemd/system/node_exporter.service << NODEEXPEND
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=prometheus
ExecStart=/home/prometheus/node_exporter/node_exporter
[Install]
WantedBy=default.target
NODEEXPEND

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

EC2_INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\")
PRIVIP=$(wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4 || die \"wget local-ipv4 has failed: $?\")

tee -a /home/ubuntu/host-node-exporter-payload.json << HOSTPAYLOADEND
{
  "ID": "host_$EC2_INSTANCE_ID",
  "Name": "consul_node_exporter",
  "Tags": "prep",
  "Address": "$PRIVIP",
  "Port": 9100,
  "Check": {
    "DeregisterCriticalServiceAfter": "60m",
    "id": "prometheus-api",
    "name": "HTTP on port 9100",
    "http": "http://$PRIVIP:9100",
    "interval": "10s",
    "timeout": "1s"
  }
}
HOSTPAYLOADEND

tee -a /home/ubuntu/docker-node-exporter-payload.json << DOCKERPAYLOADEND
{
  "ID": "docker_$EC2_INSTANCE_ID",
  "Name": "consul_node_exporter",
  "Tags": "prep",
  "Address": "$PRIVIP",
  "Port": 9323,
  "Check": {
    "DeregisterCriticalServiceAfter": "60m",
    "id": "prometheus-api",
    "name": "HTTP on port 9323",
    "http": "http://$PRIVIP:9323/metrics",
    "interval": "10s",
    "timeout": "1s"
  }
}
DOCKERPAYLOADEND

consul agent register /home/ubuntu/host-node-exporter-payload.json
consul agent register /home/ubuntu/docker-node-exporter-payload.json

# Run this after everything has mounted so that we know the ebs volume is mounted properly before the compose runs.
#cat <<EOF >/home/ubuntu/docker-compose.yml
#version: '3'
#services:
#   prep:
#      image: 'iconloop/prep-node:1905292100xdd3e5a'
#      network_mode: host
#      environment:
#         LOOPCHAIN_LOG_LEVEL: "SPAM"
#         DEFAULT_PATH: "/data/loopchain"
#         SERVICE: "jinseong"
#         LOG_OUTPUT_TYPE: "file"
#         TIMEOUT_FOR_LEADER_COMPLAIN : 120
#         MAX_TIMEOUT_FOR_LEADER_COMPLAIN : 600
#      volumes:
#         - /opt/data:/data
#      ports:
#         - 9000:9000
#         - 7100:7100
#EOF

/usr/local/bin/docker-compose -f /home/ubuntu/docker-compose.yml up -d

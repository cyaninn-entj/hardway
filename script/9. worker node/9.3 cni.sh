#!/bin/bash

# POD CIDR은 각 Worker Node마다 다르게 설정
POD_CIDR=10.200.1.0/24

HOSTNAME=$(hostname -s)

# Config Files
cat <<EOF | sudo tee /etc/cni/net.d/10-bridge.conf
{
    "cniVersion": "0.4.0",
    "name": "bridge",
    "type": "bridge",
    "bridge": "cnio0",
    "isGateway": true,
    "ipMasq": true,
    "ipam": {
        "type": "host-local",
        "ranges": [
          [{"subnet": "${POD_CIDR}"}]
        ],
        "routes": [{"dst": "0.0.0.0/0"}]
    }
}
EOF

# Loopback config
cat <<EOF | sudo tee /etc/cni/net.d/99-loopback.conf
{

    "cniVersion": "0.4.0",
    "name": "lo",
    "type": "loopback"
}
EOF
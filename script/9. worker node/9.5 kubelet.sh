#!/bin/bash
POD_CIDR=10.200.1.0/24

cp /home/ubuntu/worker1-key.pem /home/ubuntu/worker1.pem /var/lib/kubelet/
cp /home/ubuntu/worker1.kubeconfig /var/lib/kubelet/kubeconfig
cp /home/ubuntu/ca.pem /var/lib/kubernetes/

# Config File
cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "10.32.0.1"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/worker1.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/worker1-key.pem"
containerRuntimeEndpoint: "unix:///var/run/containerd/containerd.sock"
EOF

# Service File
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service
[Service]
ExecStart=/usr/local/bin/kubelet \\
  --config=/var/lib/kubelet/kubelet-config.yaml \\
  --container-runtime=remote \\
  --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
  --image-pull-progress-deadline=2m \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --network-plugin=cni \\
  --register-node=true \\
  --v=2
Restart=on-failure
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF



{
systemctl disable kubelet.service
systemctl stop kubelet.service
}

systemctl daemon-reload
systemctl reset-failed

{
systemctl enable kubelet.service
systemctl start kubelet.service
}

systemctl status kubelet.service --no-page
journalctl -u kubelet.service -m
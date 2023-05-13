# move hosts file
sudo cp hosts /etc/hosts


# Download and Install the etcd Binaries , Configure the etcd Server
{
  ETCD_VERSION=3.5.1
  wget -q --show-progress --https-only --timestamping \
    "https://github.com/etcd-io/etcd/releases/download/v3.5.1/etcd-v3.5.1-linux-amd64.tar.gz"
  tar -xvf etcd-v3.5.1-linux-amd64.tar.gz
  sudo mv etcd-v3.5.1-linux-amd64/etcd* /usr/local/bin/

  sudo mkdir -p /etc/etcd /var/lib/etcd
  sudo chmod 700 /var/lib/etcd
  sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/

  INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
  ETCD_NAME=$(hostname -s)
}

{
  echo $ETCD_VERSION
  echo $INTERNAL_IP
  echo $ETCD_NAME
}

#etcd.service systemd unit file:
# initial-cluster ip 바꿔줘야함
cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \
  --name ${ETCD_NAME} \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \
  --listen-peer-urls https://${INTERNAL_IP}:2380 \
  --listen-client-urls https://${INTERNAL_IP}:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://${INTERNAL_IP}:2379 \
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster master1=https://172.31.11.217:2380,master2=https://172.31.4.226:2380,master3=https://172.31.5.22:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start the etcd Server
{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}

#etcd cleanup.sh
#!/bin/bash
sudo systemctl stop etcd
sudo systemctl disable etcd
sudo rm /etc/systemd/system/etcd
sudo rm /etc/systemd/system/etcd.service
sudo rm /usr/lib/systemd/system/etcd
sudo rm /usr/lib/systemd/system/etcd.service
sudo systemctl daemon-reload
sudo systemctl reset-failed


rm admin.kubeconfig ca.pem 
rm ca-key.pem kube-controller-manager.kubeconfig kubernetes-key.pem
rm kubernetes.pem kube-scheduler.kubeconfig service-account-key.pem service-account.pem
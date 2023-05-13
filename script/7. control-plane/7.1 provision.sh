#!/bin/bash
sudo mkdir -p /etc/kubernetes/config/

{
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/amd64/kube-apiserver"
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/amd64/kube-controller-manager"
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/amd64/kube-scheduler"
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/linux/amd64/kubectl"
}

{
  chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
  sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/
}

{
  sudo mkdir -p /var/lib/kubernetes/

  sudo cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem \
    encryption-config.yaml front-proxy.pem front-proxy-key.pem /var/lib/kubernetes/
}
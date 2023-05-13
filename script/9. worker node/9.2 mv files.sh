#!/bin/bash

mkdir -p \
 /etc/cni/net.d \
 /opt/cni/bin \
 /var/lib/kubelet \
 /var/lib/kube-proxy \
 /var/lib/kubernetes \
 /var/run/kubernetes
 
mkdir containerd
tar -xvf crictl-v1.22.0-linux-amd64.tar.gz
tar -xvf containerd-1.5.8-linux-amd64.tar.gz -C containerd
tar -xvf cni-plugins-linux-amd64-v1.0.1.tgz -C /opt/cni/bin/
mv runc.amd64 runc
chmod +x crictl kubectl kube-proxy kubelet runc 
mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
mv containerd/bin/* /bin/
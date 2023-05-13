#!/bin/bash

# Download crictl
curl -LO "https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.22.0/crictl-v1.22.0-linux-amd64.tar.gz"

# Download runc
curl -LO "https://github.com/opencontainers/runc/releases/download/v1.0.3/runc.amd64"

# Download cni-plugin binary
curl -LO "https://github.com/containernetworking/plugins/releases/download/v1.0.1/cni-plugins-linux-amd64-v1.0.1.tgz"

# Download containerd binary
curl -LO "https://github.com/containerd/containerd/releases/download/v1.5.8/containerd-1.5.8-linux-amd64.tar.gz"

# Download kubectl binary
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.27.1/bin/linux/amd64/kubectl"

# Downlad kube-proxy binary
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.27.1/bin/linux/amd64/kube-proxy"

# Download kubelet binary
curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.27.1/bin/linux/amd64/kubelet"

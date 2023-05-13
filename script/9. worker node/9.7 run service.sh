{
    systemctl daemon-reload
    systemctl enable containerd kubelet kube-proxy
    systemctl start containerd kubelet kube-proxy
}

systemctl status containerd --no-page
systemctl status kubelet --no-page
systemctl status kube-proxy --no-page
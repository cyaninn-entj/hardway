{
    systemctl daemon-reload
    systemctl enable kube-apiserver kube-controller-manager kube-scheduler
    systemctl start kube-apiserver kube-controller-manager kube-scheduler
}

systemctl status kube-apiserver
systemctl status kube-controller-manager
systemctl status kube-scheduler

systemctl stop kube-apiserver kube-controller-manager kube-scheduler
systemctl disable kube-apiserver kube-controller-manager kube-scheduler
systemctl daemon-reload
systemctl reset-failed


# test
sudo apt-get install -y nginx

cat > kubernetes.default.svc.cluster.local <<EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF


{
  sudo mv kubernetes.default.svc.cluster.local \
    /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

  sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/
}


# nginx service restart
{
  sudo systemctl restart nginx
  sudo systemctl enable nginx
}

kubectl get componentstatuses --kubeconfig admin.kubeconfig
kubectl cluster-info --kubeconfig admin.kubeconfig
curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz

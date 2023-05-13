# --------/etc/hosts 파일 배포 deploy.sh--------
#!/bin/bash
for i in worker1 master2 master3 lb; do
  sudo scp -i /home/ubuntu/osckorea.pem /etc/hosts ubuntu@${i}:/home/ubuntu
done



#인증서 파일 배포
sudo scp -i /home/ubuntu/osckorea.pem ca.pem worker1-key.pem worker1.pem ubuntu@worker1:~/

for i in master2 master3; do
  sudo scp -i /home/ubuntu/osckorea.pem ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem front-proxy.pem front-proxy-key.pem  ubuntu@${i}:~/
done

cp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    service-account-key.pem service-account.pem front-proxy.pem front-proxy-key.pem /home/ubuntu




#구성 파일 배포
sudo scp -i /home/ubuntu/osckorea.pem worker1.kubeconfig kube-proxy.kubeconfig ubuntu@worker1:~/

for i in master2 master3; do
  sudo scp -i /home/ubuntu/osckorea.pem admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ubuntu@${i}:~/
done

cp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig /home/ubuntu




#암호화 구성 파일 배포
for i in master2 master3; do
  sudo scp -i /home/ubuntu/osckorea.pem /home/ubuntu/data-encryption/encryption-config.yaml ubuntu@${i}:~/
done

cp /home/ubuntu/data-encryption/encryption-config.yaml /home/ubuntu
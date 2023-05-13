sudo su -
{
    vim /etc/hostname
    swapoff -a
    systemctl stop ufw && ufw disable && iptables -F
    reboot
}

#로컬 피시에서 pem 파일 전송
scp -i osckorea.pem osckorea.pem ubuntu@3.35.230.237:/home/ubuntu
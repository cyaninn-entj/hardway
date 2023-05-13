sudo su -
{
    vim /etc/hostname
    swapoff -a
    systemctl stop ufw && ufw disable && iptables -F
    reboot
}

#로컬 피시에서 pem 파일 전송
scp -i osckorea.pem osckorea.pem ubuntu@13.125.38.246:/home/ubuntu
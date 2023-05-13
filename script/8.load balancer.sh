# Install Package - HAProxy
apt-get install haproxy -y

# Make openssl
openssl req  -nodes -new -x509  -keyout /etc/haproxy/api_key.pem -out /etc/haproxy/api_cert.pem -days 365
Generating a 4096 bit RSA private key
................................................................................++
.........................................................++
writing new private key to 'key.pem'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:KR
State or Province Name (full name) [Some-State]:Seoul
Locality Name (eg, city) []:Seoul
Organization Name (eg, company) [Internet Widgits Pty Ltd]:OSC
Organizational Unit Name (eg, section) []:Kubernetes
Common Name (e.g. server FQDN or YOUR name) []:conlb.YOUR DOMAIN
Email Address []:ray.lee@osckorea.com

# Merge File
cat /etc/haproxy/api_key.pem /etc/haproxy/api_cert.pem > /etc/haproxy/k8s_api.pem





# Backup haproxy default config file
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

vim /etc/haproxy/haproxy.cfg
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon
# Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private
# See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
        ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
        ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
        ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets
        tune.ssl.default-dh-param 2048
defaults
        log     global
        mode    http
        option  httplog
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http
### Controllers ###
frontend apiservers
         bind *:80
         bind *:443 ssl crt /etc/haproxy/k8s_api.pem
         http-request redirect scheme https unless { ssl_fc }
         mode http
         option forwardfor
         default_backend k8s_apiservers
frontend kube_api
         bind *:6443
         mode tcp
         option tcplog
         default_backend k8s_apiservers_6443
backend k8s_apiservers
         mode http
         balance roundrobin
         option forwardfor
         option httpchk GET / HTTP/1.1\r\nHost:kubernetes.default.svc.cluster.local
         default-server inter 10s fall 2
         server master1 172.31.6.115:80 check
         server master2 172.31.1.68:80 check
         server master3 172.31.0.222:80 check

backend k8s_apiservers_6443
         mode tcp
         option ssl-hello-chk
         option log-health-checks
         default-server inter 10s fall 2
         server master1 172.31.6.115:80 check
         server master2 172.31.1.68:80 check
         server master3 172.31.0.222:80 check


systemctl restart haproxy
curl -k https://15.165.17.246/healthz
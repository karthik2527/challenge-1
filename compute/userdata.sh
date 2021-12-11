#!/bin/bash -x

exec &> >(logger -t user-data -s)
yum update -y 
yum install -y httpd
systemctl start httpd && sudo systemctl enable httpd
yum install -y mod_ssl
sleep 10
/etc/pki/tls/certs/make-dummy-cert localhost.crt
sed -e '/SSLCertificateKeyFile/ s/^#*/#/' -i /etc/httpd/conf.d/ssl.conf
systemctl restart httpd

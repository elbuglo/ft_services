#!/bin/sh

mkdir -p /ftps/__FTPS_USERNAME__

# ssl
yes "" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-subj '/C=FR/ST=75/L=Paris/O=42/CN=lulebugl' \
-keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem 

chmod 600 /etc/ssl/private/pure-ftpd.pem

adduser -D "__FTPS_USERNAME__"
echo "__FTPS_USERNAME__:__FTPS_PASSWORD__" | chpasswd

/usr/sbin/pure-ftpd -j -Y 2 -p 21000:21000 -P "192.168.99.230"
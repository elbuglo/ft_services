#!/bin/sh

apk upgrade
apk add openssl --no-cache
apk add pure-ftpd --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted --no-cache

# ssl
yes "" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-subj '/C=FR/ST=75/L=Paris/O=42/CN=lulebugl' \
-keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem 

chmod 600 /etc/ssl/private/pure-ftpd.pem

adduser -D "admin"
echo "admin:admin1234" | chpasswd

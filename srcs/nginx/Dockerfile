FROM alpine

USER root

COPY srcs/install.sh /tmp/install.sh
COPY srcs/nginx.conf /etc/nginx/nginx.conf
COPY srcs/index.html /var/www/localhost/htdocs/index.html

RUN sh /tmp/install.sh 

EXPOSE 22 80 443

ENTRYPOINT /etc/init.d/sshd start; nginx -g "daemon off;"

FROM alpine

RUN apk upgrade && \
    apk add openssl && \
    apk add pure-ftpd --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted --no-cache && \
    apk add openrc --no-cache

COPY install.sh /tmp/install.sh

RUN chmod 755 /tmp/install.sh
RUN /tmp/install.sh

EXPOSE 21 30021

##FROM alpine
##
##RUN apk upgrade && \
##    echo -ne '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' \
##      >> /etc/apk/repositories && \
##    apk update && \
##	  apk add openssl && \
##    apk add pure-ftpd@testing="1.0.49-r0" && \
##    rm -rf /var/cache/apk/*
##
##COPY install.sh /tmp/install.sh
##
##RUN chmod 755 /tmp/install.sh
##RUN /tmp/install.sh
##
##EXPOSE 21 30021
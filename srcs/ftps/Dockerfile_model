FROM alpine

RUN apk upgrade && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update && \
    apk add openssl && \
    apk add pure-ftpd && \
    rm -rf /var/cache/apk/*

COPY install.sh /tmp/install.sh

RUN chmod 755 /tmp/install.sh
RUN /tmp/install.sh

EXPOSE 21 21000
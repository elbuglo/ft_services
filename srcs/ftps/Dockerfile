FROM alpine

RUN apk upgrade && \
    apk add openssl && \
    apk add pure-ftpd --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted --no-cache

COPY install.sh /tmp/install.sh

RUN chmod 755 /tmp/install.sh

EXPOSE 21 21000

ENTRYPOINT sh /tmp/install.sh


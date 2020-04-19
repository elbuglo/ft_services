FROM alpine

USER root

COPY install.sh /tmp/install.sh

RUN chmod 755 /tmp/install.sh
RUN /tmp/install.sh

EXPOSE 21 21022

ENTRYPOINT pure-ftpd -j -Y 2 -p 21022:21022 -P "192.168.99.100"
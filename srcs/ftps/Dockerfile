FROM alpine

USER root

COPY srcs/install.sh /tmp/install.sh

RUN chmod 755 /tmp/install.sh
RUN /tmp/install.sh

RUN mkdir -p /etc/telegraf
COPY srcs/telegraf.conf /etc/telegraf.conf
COPY srcs/telegraf.conf /etc/telegraf/telegraf.conf

EXPOSE 21 21000

ENTRYPOINT /etc/init.d/telegraf start; pure-ftpd -j -Y 2 -p 21000:21000 -P 192.168.99.100
##192.168.99.101
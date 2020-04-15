FROM alpine:latest

RUN mkdir /etc/telegraf \
&& wget https://dl.influxdata.com/telegraf/releases/telegraf-1.13.3-static_linux_amd64.tar.gz \
&& tar -C . -xzf telegraf-1.13.3-static_linux_amd64.tar.gz \
&& chmod +x telegraf/* \
&& cp telegraf/telegraf /usr/bin/ \
&& rm -rf *.tar.gz* telegraf/

COPY telegraf.conf /etc/telegraf/telegraf.conf

EXPOSE 4999

ENTRYPOINT usr/bin/telegraf $@
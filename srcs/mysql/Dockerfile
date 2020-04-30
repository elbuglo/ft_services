FROM alpine:latest

RUN apk update \
&& apk add mariadb mariadb-client && apk add --no-cache --upgrade bash \
&& rm -rf /var/cache/apk/*

COPY ./setup.sh .
COPY ./init_mysql.sh .
COPY wp.sql .

RUN chmod 777 setup.sh
RUN chmod 777 init_mysql.sh

EXPOSE 3306

ENTRYPOINT [ "./setup.sh" ]
FROM alpine:3.21

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

RUN mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

RUN sed -i '/skip-networking/d' /etc/my.cnf.d/mariadb-server.cnf

COPY /tools/maria_script.sh /tmp/maria_script.sh
RUN chmod +x /tmp/maria_script.sh

ENTRYPOINT ["/tmp/maria_script.sh"]


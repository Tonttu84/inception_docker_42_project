FROM alpine:3.21

RUN apk update;
RUN apk add --no-cache php php-fpm php-mysqli php-phar php-json php-session php-mbstring php-curl php-dom php-xml \
php-gd mysql-client
RUN mkdir -p /var/www/html && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 -C /var/www/html && \
    rm latest.tar.gz

RUN adduser -S www-data -G www-data

RUN apk add --no-cache curl && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    rm -f wp-cli.phar
    


COPY /tools/wordpress_script.sh /wordpress_script.sh
RUN chmod +x /wordpress_script.sh

COPY /conf/www.conf /etc/php83/php-fpm.d/www.conf

RUN chown root:root /etc/php83/php-fpm.d/www.conf \
    && chmod 644 /etc/php83/php-fpm.d/www.conf

ENTRYPOINT ["/wordpress_script.sh"]

FROM alpine:3.21


RUN apk update
RUN apk add --no-cache nginx openssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/johannes.key \
    -out /etc/ssl/certs/johannes.crt \
  -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Hive Helsinki/OU=/CN=johannes.hive.fi"

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 8443
CMD ["nginx", "-g", "daemon off;"]





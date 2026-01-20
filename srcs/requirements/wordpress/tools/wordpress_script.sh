#!/bin/sh
set -eu



: "${MariaBossPass:?Environment variable MariaBossPass is required}"
: "${WriterPass:?Environment variable WriterPass is required}"
: "${BossPass:?Environment variable BossPass is required}"
: "${WP_HOME:?Environment variable WP_HOME is required}"
: "${WP_SITEURL:?Environment variable WP_SITEURL is required}"

MYSQL_USER=MariaBoss
MYSQL_HOSTNAME="mariadb_service"
MYSQL_DATABASE=myMariaDB

cd /var/www/html

if [ ! -f index.php ]; then
    wget https://wordpress.org/latest.tar.gz
    tar xfz latest.tar.gz --strip-components=1
    rm -f latest.tar.gz
fi

INIT_FLAG="/var/www/html/.wp_initialized"

if [ ! -f "$INIT_FLAG" ]; then
  echo "Initializing WordPress..."

  wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MariaBossPass" \
    --dbhost="$MYSQL_HOSTNAME" \
    --path=/var/www/html \
    --skip-check \
    --force

  CONFIG_PATH="/var/www/html/wp-config.php"
  if ! grep -q "WP_HOME" "$CONFIG_PATH"; then
  sed -i "/^<\?php/a \
define('WP_HOME', getenv('WP_HOME'));\n\
define('WP_SITEURL', getenv('WP_SITEURL'));\n\
define('FORCE_SSL_ADMIN', true);\n\
\$_SERVER['HTTPS'] = 'on';\n" "$CONFIG_PATH"
fi


  until wp db check --path=/var/www/html > /dev/null 2>&1; do
    echo "Waiting for MariaDB to be ready..."
    sleep 2
  done

  wp core install \
    --url="${WP_HOME}" \
    --title="Sample Site" \
    --admin_user="siteboss" \
    --admin_password="${BossPass}" \
    --admin_email="boss@example.com" \
    --path=/var/www/html

  wp user create writer writer@example.com --role=author --user_pass="${WriterPass}" --path=/var/www/html || echo "User 'writer' already exists."

  wp option update siteurl "${WP_HOME}" --path=/var/www/html
  wp option update home "${WP_HOME}" --path=/var/www/html

  touch "$INIT_FLAG"
else
  echo "WordPress already initialized. Skipping setup."
fi

exec php-fpm83 -F
#!/bin/sh
set -eu

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

LOGFILE="/var/log/mariadb_init.log"
mkdir -p "$(dirname "$LOGFILE")"

log() {
    printf "$1\n"
    printf "$1\n" >> "$LOGFILE"
}

: "${myMariaPass:?Environment variable myMariaPass is required}"
: "${MariaBossPass:?Environment variable MariaBossPass is required}"

USERNAME="${USER:-DEFAULTUSER}"
ADMIN="MariaBoss"
myMaria="myMariaDB"
SOCKET_PATH="/run/mysqld/mysqld.sock"

INIT_FLAG="/var/lib/mysql/.initialized"

if [ ! -f "$INIT_FLAG" ]; then
  log "${BLUE}Starting MariaDB in background for init...${NC}"
  mariadbd-safe --skip-networking &
  pid="$!"

  log "${YELLOW}Waiting for MariaDB to become available...${NC}"
  while ! mariadb-admin ping --silent; do
      sleep 1
  done

  log "${GREEN}Running initial SQL setup...${NC}"
mariadb -u root <<-EOSQL
    DELETE FROM mysql.user WHERE User = '';
    CREATE DATABASE IF NOT EXISTS ${myMaria};
    CREATE USER IF NOT EXISTS '${USERNAME}'@'%' IDENTIFIED BY '${myMariaPass}';
    GRANT ALL PRIVILEGES ON ${myMaria}.* TO '${USERNAME}'@'%';
    CREATE USER IF NOT EXISTS '${ADMIN}'@'%' IDENTIFIED BY '${MariaBossPass}';
    GRANT ALL PRIVILEGES ON ${myMaria}.* TO '${ADMIN}'@'%';
    FLUSH PRIVILEGES;
EOSQL

  log "${RED}Stopping init MariaDB...${NC}"
  pkill -f mariadbd-safe
  pkill -f mariadbd

  log "${YELLOW}Waiting for all MariaDB processes to shut down...${NC}"
  while pgrep -f mariadbd > /dev/null || pgrep -f mariadbd-safe > /dev/null; do
      sleep 1
  done

  touch "$INIT_FLAG"
fi

log "${BLUE}Starting MariaDB in foreground with bind-address=0.0.0.0...${NC}"
exec mariadbd --bind-address=0.0.0.0 --port=3306 --user=root --socket=/run/mysqld/mysqld.sock



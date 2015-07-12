#!/bin/bash

sudo touch /var/backups/db.sql.gz

echo "/var/backups/db.sql.gz {
  daily
  rotate 8
  nocompress
  create 640 root adm
  postrotate
    docker run -i --link mysql_mysql_1:mysql --rm mariadb sh -c 'exec mysqldump -h\"\$MYSQL_PORT_3306_TCP_ADDR\" -P\"\$MYSQL_PORT_3306_TCP_PORT\" -uroot -p\"\$MYSQL_ENV_MYSQL_ROOT_PASSWORD\" --all-databases --events' > /var/backups/db.sql
    gzip -9f /var/backups/db.sql
  endscript
}" | sudo tee /etc/logrotate.d/mysql-bkup > /dev/null

sudo logrotate -f /etc/logrotate.d/mysql-bkup

echo "Done! Backups will be made daily to /var/backups/db.sql.gz"

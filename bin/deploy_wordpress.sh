#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 URL (e.g. blog.example.com)"
	exit 1
fi

set -e

URL=$1
TLD=${URL##*.}
NONTLD=${URL%.*}
DOMAIN=${NONTLD##*.}
if [ "$NONTLD" != "$DOMAIN" ]; then
	SUBDOMAIN=${NONTLD%.*}
	SHORT="${DOMAIN}_${SUBDOMAIN}"
	REVERSE="$TLD.$DOMAIN.$SUBDOMAIN"
else
	SUBDOMAIN=''
	SHORT="${DOMAIN}_${TLD}"
	REVERTSE="$TLD.$DOMAIN"
fi
SLUG=$(echo $URL | tr '.' '_')
PASSWORD=$(date | md5sum | awk '{print $1}')

red='\033[0;31m'
green='\033[0;32m'
orange='\033[0;33m'
blue='\033[0;34m'
nocolor='\033[0m'

[ -d apps/$SHORT ] || mkdir -p apps/$SHORT

# Initial installation
echo "#!/bin/bash

mkdir -p /data/$SHORT/" > apps/$SHORT/install.sh
chmod +x apps/$SHORT/install.sh
sudo `pwd`/apps/$SHORT/install.sh

# Database
echo -e "${blue}Creating database $SLUG...${nocolor}"
sudo docker start mysql_mysql_1
echo "CREATE DATABASE $SLUG;
  CREATE USER '$SLUG'@'%' IDENTIFIED BY '$PASSWORD';
  GRANT ALL ON $SLUG.* TO '$SLUG'@'%';
  FLUSH PRIVILEGES;
" | sudo docker run -i --link mysql_mysql_1:mysql --rm mariadb \
         sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" \
                           -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
echo -e "${green}Database created${nocolor}"
echo

# Nginx config
echo -e "${blue}Creating nginx site $REVERSE...${nocolor}"
echo "server {
        server_name $URL;

        access_log  /var/log/nginx/${REVERSE}_access.log;
        error_log   /var/log/nginx/${REVERSE}_error.log notice;

        client_max_body_size 64M;

        location / {
                proxy_pass http://$SHORT;
        }
}" > /etc/nginx/sites-available/$REVERSE
[ -f /etc/nginx/sites-enabled/$REVERSE ] && rm /etc/nginx/sites-enabled/$REVERSE
ln -s /etc/nginx/sites-available/$REVERSE /etc/nginx/sites-enabled/$REVERSE
echo -e "${green}Config written${nocolor}"
echo

# Docker-compose config
echo -e "${blue}Creating docker container $SHORT_wordpress_1...${nocolor}"
cd apps/$SHORT
echo "wordpress:
  image: wordpress
  restart: always
  environment:
   - WORDPRESS_DB_USER=$SLUG
   - WORDPRESS_DB_PASSWORD=$PASSWORD
   - WORDPRESS_DB_NAME=$SLUG
   - NGINX_UPSTREAM=$SHORT
  external_links:
   - mysql_mysql_1:mysql
  volumes:
   - /data/$SHORT/:/var/www/html/
" > docker-compose.yml
sudo docker-compose up -d
cd - > /dev/null
sudo docker ps
echo -e "${green}Container up${nocolor}"

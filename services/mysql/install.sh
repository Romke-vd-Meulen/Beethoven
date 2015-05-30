#!/bin/bash

mkdir -p /data/mysql/

cd services/mysql
PASSWORD=$(date | md5sum | awk '{print $1}')
sed -i "s/INSERT_PASSWORD/$PASSWORD/g" docker-compose.yml
docker-compose up -d

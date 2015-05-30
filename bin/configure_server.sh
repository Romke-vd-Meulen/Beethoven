#!/bin/bash

cp lib/docker-gen/docker-gen /etc/nginx/docker-gen
cp lib/docker-gen/docker-gen-upstream-template /etc/nginx/docker-gen-upstream-template
cp lib/docker-gen/docker-gen-upstream-service /etc/nginx/docker-gen-upstream-service

cp lib/upstart/docker-upstreams.conf /etc/init/docker-upstreams.conf
initctl start docker-upstreams

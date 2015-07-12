# Beethoven

![Beethoven](https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Beethoven.jpg/199px-Beethoven.jpg)

Beethoven is a collection of Bash scripts and config files written for [Docker Compose](https://docs.docker.com/compose/) that make it child's play to deploy applications on your Docker-enabled server. Beethoven is geared mainly toward people who want to quickly deploy a number of simple applications on their server, without having to worry about how to configure and wire it all. However, Beethoven dilligently writes everything he does to config files, so if you feel brave enough to improve upon his work, you can.

To make things easy for you, Beethoven makes some assumptions about how things should be done:

 * He doesn't create separate database containers for each app you create - that's way to bombastic for his tastes. A single MySQL or Redis container is enough to link multiple apps against. And using the scripts Beethoven provides, you can have these up with a single command.
 * Want a new app, say a Wordpress blog? No problem! Run the script with the right arguments and Beethoven will generate the necessary configuration, then bring your new container online. All the Docker config for your new Wordpress blog is written inside Beethoven, so you can `git add` them and keep a spare copy of your site config safe in an off-site (secret) repo.
 * Do you want your blog hosted at 123.0.1.2:8080? I didn't think so. Beethoven sets up [nginx](http://nginx.org/) as a reverse proxy to assign a pretty URL to containers it sets up. Using [this approach](http://blog.romkevandermeulen.nl/2015/02/19/docker-gen-automatic-nginx-config-with-a-human-touch/), nginx config is automatically generated and kept up-to-date so that after a reboot, your apps will come back online without a hitch.

**Take note!** Beethoven is in beta, with support and further development only provided as time allows.

Beethoven can currently deploy the following apps and services:

 * MySQL (MariaDB)
 * Redis
 * Wordpress

## Installation

Clone this repo anywhere on your server, it doesn't really matter where. Then run:

```
$ bin/configure_server.sh
```

## Installing a service

```
$ services/mysql/install.sh
```

You may also want to configure automatic database backups by running `servies/mysql/setup-backup.sh`.

## Deploying an app

```
$ bin/deploy_wordpress.sh blog.example.com

Creating database blog_example_com...
mysql_mysql_1
Database created

Creating nginx site com.example.blog...
Config written

Creating docker container ...
Creating exampleblog_wordpress_1...
CONTAINER ID        IMAGE                     COMMAND                CREATED             STATUS                  PORTS                                    NAMES
2760a5068e76        wordpress:4               "/entrypoint.sh apac   1 seconds ago       Up Less than a second   80/tcp                                   exampleblog_wordpress_1        
15f8323fd001        mariadb:10                "/docker-entrypoint.   5 minutes ago       Up 5 minutes            3306/tcp                                 mysql_mysql_1                  
Container up
```

The docker-compose container config for your new blog was written to `apps/exampleblog/`. Of course the first thing you want to do is keep this config safe in case little green men invade your server.

```
$ git add apps/example_blog
$ git commit -m "Added my latest and greatest new blog!"
$ git push myrepo master
```

The configuration you've just added contains sensitive information such as passwords, so make sure you don't push it to a public repo!

## Dude! Where are my files?

* the docker-compose config files are written inside Beethoven to `app/` and `services/`.
* `/data` on your host system contains directories that are mounted inside your app and service containers. Make sure to have backups of this directory.
* `/etc/nginx/sites-available` contains the nginx configuration for you apps. Note that these `proxy_pass` requests to the containers.
* `/etc/nginx/conf.d/docker_upstream_hosts.conf` maps container IP's to more readable nginx upstreams. This file is generated and maintained by [docker-gen](https://github.com/jwilder/docker-gen) so it's useless to edit it manually.

## Moving to a different server

...has never been so easy! All you need to do:

* Install Beethoven on your new server. Make sure you `git clone` Beethoven from the repo you pushed your config files to, not this repo.
* Stop the containers on your old server, then copy `/data` and `/etc/nginx/sites-available` to your new server. Link the sites you want back up from `sites-available` to `sites-enabled`.
* For each service you use, then each app, go into the matching Beethoven dir and run `docker-compose up -d`.
* Now reload your nginx: `service nging reload`. Your apps should now be online. Take note if you have to change your DNS settings it may take a while for traffic to be directed to your new server.

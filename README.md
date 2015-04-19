# Beethoven

Beethoven is a collection of Bash scripts and config files written for [Docker Compose](https://docs.docker.com/compose/) that make it simple to deploy applications on your Docker-enabled server.

To make things easy for you, it makes some assumptions on how to do things. For backing services like MySQL or Redis, it defines one Compose configuration. For your apps, you run a script which generates a Compose config file. The generated config is placed in your clone of this repo, so you can commit it and store it in a private repository off-server.

To assign URL's to your apps, Beethoven sets env options on your Docker containers that work together with Docker-gen and nginx, as demonstrated in [this article](http://blog.romkevandermeulen.nl/2015/02/19/docker-gen-automatic-nginx-config-with-a-human-touch/).

## Example
```
bin/deploy_wordpress.sh blog.example.com
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

What happened here? `bin/deploy_wordpress.sh` connected to MySQL (which you can install by going into `services/mysql` and running `./install.sh`) and created a new database and user/password. It then generated config files for nginx (`/etc/nginx/sites-available/com.example.blog`) and Compose (`apps/example_blog/docker-compose.yml`) and brought an instance of the new app online.

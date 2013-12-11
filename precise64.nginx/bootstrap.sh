#!/usr/bin/env bash

echo "--Starting script..."

echo "--Updating..."
sudo apt-get update

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "--Installing basic packages..."
sudo apt-get -y install vim
sudo apt-get -y install curl
sudo apt-get -y install build-essential
sudo apt-get -y install python-software-properties

echo "--Adding repositories..."
sudo add-apt-repository ppa:ondrej/php5 -y
sudo add-apt-repository ppa:nginx/stable -y
sudo apt-get update

echo "--Installing PHP"

sudo apt-get -y install php5-fpm
sudo apt-get -y install php5-cli
sudo apt-get -y install php5-mysql php5-curl php5-gd php5-mcrypt

echo "--Configuring PHP"

#Date TimeZone
sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php5/cli/php.ini
sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/cli/php.ini

echo "--Installing Git"

sudo apt-get -y install git-core git-flow

echo "--Installing composer"

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--Installing Nginx"

sudo apt-get -y install nginx
# curl https://raw.github.com/h5bp/server-configs-nginx/master/mime.types > /etc/nginx/mime.types

# sed -i "s/user .*/user www-data www-data;/" /etc/nginx/nginx.conf
# sed -i "s/worker_processes .*/worker_processes 2;/" /etc/nginx/nginx.conf
# sed -i "s/root .*/root \/var\/www\/html;/" /etc/nginx/sites-available/default
# sed -i "s/index .*/index index\.php index\.html index\.htm;/1" /etc/nginx/sites-available/default

mkdir -p /var/www/html
echo "<?php phpinfo();?>" > /var/www/html/index.php

sudo service nginx restart

echo "--Installing Mysql"

sudo apt-get -y install mysql-server

# sed -i "s/bind-address.*/bind-address = 0\.0\.0\.0/" /etc/mysql/my.cnf

sudo service mysql restart

echo "--Finishing script..."

#!/usr/bin/env bash

echo "--Starting script..."
export DEBIAN_FRONTEND=noninteractive

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
sudo apt-get -y install php5-mysql php5-curl php5-gd php5-mcrypt php5-json php5-apcu

echo "--Configuring PHP"

#Date TimeZone
sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php5/cli/php.ini
sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/cli/php.ini

sed -i "s/;date.timezone =/date.timezone = UTC/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/fpm/php.ini

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--Installing Git"

sudo apt-get -y install git-core git-flow

echo "--Installing composer"

curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--Installing Nginx"

sudo apt-get -y install nginx
sudo service nginx stop

mkdir -p /var/www/html
mkdir -p /var/www/example.com
echo "<?php phpinfo();?>" > /var/www/html/index.php
echo "<?php phpinfo();?>" > /var/www/example.com/index.php

sudo chown -R www-data:www-data /var/www/example.com
sudo chmod -R go-rwx /var/www/example.com
sudo chmod -R g+rw /var/www/example.com
sudo chmod -R o+r /var/www/example.com

sudo cp -ru /vagrant/files/nginx /etc
sudo ln -s /etc/nginx/sites-available/example.com /etc/nginx/sites-enabled/example.com

sudo service nginx restart
sudo service php5-fpm restart

echo "--Installing Mysql"

sudo apt-get -y install mysql-server

sudo service mysql restart

echo "--Finishing script..."

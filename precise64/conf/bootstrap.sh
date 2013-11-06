#!/usr/bin/env bash

echo ">>> Starting Install Script"

sudo apt-get update
#sudo apt-get upgrade -y

# Install MySQL without prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo ">>> Installing Base Items"

sudo apt-get install -y vim
sudo apt-get install -y curl
sudo apt-get install -y build-essential
sudo apt-get install -y python-software-properties

sudo add-apt-repository -y ppa:ondrej/php5
sudo apt-get update
sudo apt-get install -y git-core php5-cli php5-fpm php5-mysql php5-curl php5-gd php5-mcrypt php5-xdebug

# xdebug Config
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo ">>> Installing Composer"

# Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo ">>> Installing Mysql"
# Mysql
sudo apt-get install -y mysql-server
sudo service mysqld restart

echo ">>> Installing Nginx"
# Nginx
sudo apt-get install -y nginx

curl https://raw.github.com/h5bp/server-configs-nginx/master/mime.types > /etc/nginx/mime.types
sudo cp /vagrant/conf/nginx/nginx.conf /etc/nginx/
sudo cp /vagrant/conf/nginx/sites-available/* /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/* /etc/nginx/sites-enabled/

sudo mkdir /etc/nginx/conf
sudo mkdir /etc/nginx/logs
sudo curl https://raw.github.com/h5bp/server-configs-nginx/master/conf/h5bp.conf > /etc/nginx/conf/h5bp.conf
sudo curl https://raw.github.com/h5bp/server-configs-nginx/master/conf/expires.conf > /etc/nginx/conf/expires.conf
sudo curl https://raw.github.com/h5bp/server-configs-nginx/master/conf/x-ua-compatible.conf > /etc/nginx/conf/x-ua-compatible.conf
sudo curl https://raw.github.com/h5bp/server-configs-nginx/master/conf/protect-system-files.conf > /etc/nginx/conf/protect-system-files.conf
sudo curl https://raw.github.com/h5bp/server-configs-nginx/master/conf/cross-domain-fonts.conf > /etc/nginx/conf/cross-domain-fonts.conf

sudo service nginx restart
sudo service php5-fpm restart

echo ">>> End script"

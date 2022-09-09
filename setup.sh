#!/bin/bash
# Author: Alperen Sah
#Date 17.08.2022
clear
PHP_VERSION=8.1
apt update -y
apt install curl gnupg2 ca-certificates lsb-release -y
echo "---------- NGINX INSTALL ----------"
echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
| tee /etc/apt/sources.list.d/nginx.list

curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
apt update
apt install nginx -y
systemctl start nginx.service
systemctl enable nginx.service
echo "---------- NGINX INSTALL FINISH ----------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "---------- PHP8.1 INSTALL ----------"
apt-get install software-properties-common
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt update -y
apt-get install php$PHP_VERSION php$PHP_VERSION-fpm -y
sed -i 's/memory_limit = 128M/memory_limit = 1G/' /etc/php/$PHP_VERSION/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 60/' /etc/php/$PHP_VERSION/cli/php.ini
touch phpinfo.php && echo '<?php phpinfo(); ?>' > phpinfo.php && mv phpinfo.php /usr/share/nginx/html/
sed -i 's/listen.owner \= www-data/listen.owner \= nginx/g' /etc/php/8.1/fpm/pool.d/www.conf
sed -i 's/listen.group \= www-data/listen.group \= nginx/g' /etc/php/8.1/fpm/pool.d/www.conf
service php$PHP_VERSION-fpm start && nginx -s reload
php -v
echo "---------- PHP INSTALL FINISH ----------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "---------- MYSQL 8.0 INSTALL START ----------"
apt update -y
apt install apt-transport-https wget -y
wget -O- http://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | gpg --dearmor | tee /usr/share/nginx/keyrings/mysql.gpg
echo 'deb [signed-by=/usr/share/nginx/keyrings/mysql.gpg] http://repo.mysql.com/apt/debian bullseye mysql-8.0' | tee /etc/apt/sources.list.d/mysql.list
apt update -y
apt install mysql-community-server -y
apt policy mysql-community-server
systemctl status mysql
mysql_secure_installation
echo "---------- MYSQL 8.0 INSTALL FINISH ----------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "----------------------------------------"
echo "---------- phpMyAdmin 5.2.0 INSTALL START ----------"
apt update -y
apt install -y php8.1-json php8.1-mbstring php8.1-xml
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.0/phpMyAdmin-5.2.0-all-languages.tar.gz
tar -zxvf phpMyAdmin-5.2.0-all-languages.tar.gz
mv phpMyAdmin-5.2.0-all-languages /usr/share/nginx/phpMyAdmin
cp -pr /usr/share/nginx/phpMyAdmin/config.sample.inc.php /usr/share/nginx/phpMyAdmin/config.inc.php
mkdir /usr/share/nginx/phpMyAdmin/tmp
chmod 777 /usr/share/nginx/phpMyAdmin/tmp
chown -R www-data:www-data /usr/share/nginx/phpMyAdmin/
find /usr/share/nginx/phpMyAdmin/ -type d -exec chmod 755 {} \;
find /usr/share/nginx/phpMyAdmin/ -type f -exec chmod 644 {} \;
echo "----------------------------------------"
openssl rand -base64 22
echo "----------------------------------------"
service nginx restart && service php8.1-fpm restart
echo "---------- phpMyAdmin 5.2.0 INSTALL FINISH ----------"

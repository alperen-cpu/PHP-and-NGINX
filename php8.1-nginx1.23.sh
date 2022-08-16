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

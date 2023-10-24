#!/bin/bash

db_name="db"
db_user="user"
newpass="pass"
rootpass="pass"

# PHP-FPM'yi başlat
service php8.1-fpm start

# MariaDB başlat
service mariadb start

mariadb -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('$rootpass') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

mariadb --user=root --password=$rootpass -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$rootpass';CREATE DATABASE $db_name;use $db_name;CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$newpass';GRANT ALL PRIVILEGES ON $db_name.* TO $db_user@'localhost';FLUSH PRIVILEGES;"

chown -R www-data:www-data /usr/share/nginx/html

find /usr/share/nginx/html -type d -exec chmod 755 {} \;
find /usr/share/nginx/html -type f -exec chmod 644 {} \;

rm -rf /usr/lib/php/8.1/sapi/apache2
rm -rf /usr/lib/apache2
rm -rf /usr/sbin/apache2
rm -rf /usr/share/bug/apache2-bin
rm -rf /usr/share/doc/apache2-bin
rm -rf /var/lib/dpkg/info/apache2-bin.list
rm -rf /var/lib/dpkg/info/apache2-bin.md5sums
rm -rf /var/lib/php/modules/8.1/apache2
rm -rf /var/lib/apache2
rm -rf /etc/apache2
rm -rf /usr/lib/php/8.1/sapi/apache2

# Nginx'i arka planda çalıştır
nginx -g "daemon off;"
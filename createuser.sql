CREATE DATABASE phpmyadmin;
USE phpmyadmin;
--mysql -u root -p $you-password < /usr/share/nginx/phpMyAdmin/sql/create_tables.sql | import
CREATE USER 'pma'@'localhost' IDENTIFIED BY 'pmapass';
GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'pma'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
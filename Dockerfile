FROM debian:buster-slim

# Update and install required packages
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y sudo nano curl wget gnupg2 ca-certificates lsb-release debian-archive-keyring apt-transport-https software-properties-common unzip

# Nginx signing key
RUN curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# Verify that the downloaded file
RUN gpg --dry-run --quiet --no-keyring --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

# Install Nginx
RUN echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
    > /etc/apt/sources.list.d/nginx.list && \
    apt-get update -y && apt-get install nginx -y && rm -rfv /etc/nginx/conf.d/default.conf

# Install PHP8.1
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list && wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - && \
    apt-get update -y && apt install -y --no-install-recommends php8.1

# PHP8.1 Extensions
RUN apt-get install -y --no-install-recommends php8.1-fpm php8.1-cli php8.1-common php8.1-mysql php8.1-zip php8.1-gd php8.1-mbstring php8.1-curl php8.1-xml php8.1-bcmath php8.1-imagick php8.1-intl && rm -rfv /etc/php/8.1/apache2/ && rm -rfv /etc/php/apache2/ 

# PHP8.1 Settings
RUN sed -i 's/listen.owner \= www-data/listen.owner \= nginx/g' /etc/php/8.1/fpm/pool.d/www.conf && \
    sed -i 's/listen.group \= www-data/listen.group \= nginx/g' /etc/php/8.1/fpm/pool.d/www.conf && \
    sed -i 's#;date.timezone =#date.timezone = Europe/Istanbul#' /etc/php/8.1/fpm/php.ini && \
    sed -i 's#;date.timezone =#date.timezone = Europe/Istanbul#' /etc/php/8.1/cli/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# MariaDB Install

RUN mkdir -p /etc/apt/keyrings && curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'

RUN echo "deb [signed-by=/etc/apt/keyrings/mariadb-keyring.pgp] https://mirror.truenetwork.ru/mariadb/repo/11.1/debian buster main" > /etc/apt/sources.list.d/mariadb.list

RUN apt-get update && apt-get install -y mariadb-server && rm -rfv /usr/share/nginx/html/*

COPY start.sh /root/docker-images/
COPY nginx/* /etc/nginx/conf.d
COPY my-app/* /usr/share/nginx/html/
CMD ["/bin/bash", "/root/docker-images/start.sh"]
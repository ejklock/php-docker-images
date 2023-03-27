FROM php:7.4-fpm-alpine

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN apk update && \
    apk add --no-cache git curl postgresql-dev libpng-dev oniguruma-dev libzip-dev openldap-dev libxml2-dev unzip libwebp-dev libpng-dev gmp-dev freetype-dev imagemagick-dev libjpeg-turbo-dev libpng-dev libzip-dev g++ && \
    rm -rf /var/cache/apk/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd gettext zip pgsql pdo_pgsql pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap opcache sockets

RUN pecl install imagick-3.4.4 && \
    docker-php-ext-enable imagick

RUN echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN adduser -D -g 'www-data' -G www-data,root -u $uid -h /home/$user $user && \
    mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER app

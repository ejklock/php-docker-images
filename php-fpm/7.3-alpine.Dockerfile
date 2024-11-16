FROM php:7.4.33-fpm-alpine

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

RUN apk update && apk upgrade && apk add --no-cache \
    git curl autoconf make postgresql-dev libpng-dev \
    oniguruma-dev libzip-dev openldap-dev libxml2-dev \
    unzip libwebp-dev libpng-dev gmp-dev freetype-dev \
    imagemagick-dev libjpeg-turbo-dev libpng-dev \
    libzip-dev g++ gettext-dev && \
    rm -rf /var/cache/apk/*

RUN docker-php-ext-configure gd && \
    docker-php-ext-install -j$(nproc) gd gettext zip pgsql pdo_pgsql pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap opcache sockets

RUN pecl install imagick-3.4.4 xdebug-3.1.6 && \
    docker-php-ext-enable imagick xdebug

RUN echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN addgroup -g $uid $user && adduser -u $uid -G $user -h /home/$user -s /bin/sh -D $user


WORKDIR /var/www/app

USER ${user}

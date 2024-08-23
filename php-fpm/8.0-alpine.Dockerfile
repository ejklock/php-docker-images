FROM php:8-fpm-alpine

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=www-data

RUN apk update && apk upgrade && apk add --no-cache \
    git linux-headers curl postgresql-dev ${PHPIZE_DEPS} imagemagick \ 
    imagemagick-dev gettext-dev libpng-dev oniguruma-dev \
    libzip-dev openldap-dev libxml2-dev unzip libwebp-dev \
    libpng-dev gmp-dev freetype-dev imagemagick-dev \
    libjpeg-turbo-dev libpng-dev libzip-dev g++ \
    autoconf make && \
    rm -rf /var/cache/apk/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd gettext zip pgsql pdo_pgsql pdo_mysql mbstring intl exif pcntl bcmath gmp mysqli ldap opcache sockets

RUN pecl install -o -f imagick xdebug \
    &&  docker-php-ext-enable imagick xdebug

RUN echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN if ! getent group www-data >/dev/null; then addgroup -g 1000 -S www-data; fi && \
    if ! id -u $user >/dev/null 2>&1; then adduser -u $uid -D -S -G www-data $user; fi && \
    mkdir -p /home/$user/.composer && chown -R $user:$user /home/$user


WORKDIR /var/www/app

USER ${user}

FROM php:7.0-fpm-alpine

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system dependencies
RUN apk update && apk add --no-cache \
    git \
    icu-dev \
    curl \
    autoconf \
    make \
    postgresql-dev \
    libpng-dev \
    oniguruma-dev \
    libzip-dev \
    openldap-dev \
    libxml2-dev \
    unzip \
    libwebp-dev \
    gmp-dev \
    freetype-dev \
    imagemagick-dev \
    libjpeg-turbo-dev \
    g++ \
    gettext-dev && \
    rm -rf /var/cache/apk/*

# Install and configure PHP extensions
RUN docker-php-ext-configure gd && \
    docker-php-ext-install -j$(nproc) \
    gd \
    gettext \
    zip \
    pgsql \
    pdo_pgsql \
    pdo_mysql \
    mbstring \
    intl \
    exif \
    pcntl \
    bcmath \
    gmp \
    mysqli \
    ldap \
    opcache \
    sockets

# Install PECL extensions
RUN pecl install imagick-3.4.4 xdebug-2.6.1 && \
    docker-php-ext-enable imagick xdebug

# Configure PHP
RUN echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and group
RUN addgroup -g $uid $user && \
    adduser -u $uid -G $user -h /home/$user -s /bin/sh -D $user

WORKDIR /var/www/app

USER ${user}
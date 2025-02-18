FROM php:7.3-fpm-alpine

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system dependencies
RUN apk add --no-cache \
    autoconf \
    curl \
    freetype-dev \
    g++ \
    gettext-dev \
    git \
    gmp-dev \
    imagemagick-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    make \
    oniguruma-dev \
    openldap-dev \
    postgresql-dev \
    unzip && \
    rm -rf /var/cache/apk/*

# Install and configure PHP extensions
RUN docker-php-ext-configure gd && \
    docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    gd \
    gettext \
    gmp \
    intl \
    ldap \
    mbstring \
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    sockets \
    zip

# Install PECL extensions
RUN pecl install imagick-3.4.4 xdebug-3.1.6 && \
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
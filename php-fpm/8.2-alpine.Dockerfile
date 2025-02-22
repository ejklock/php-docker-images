FROM php:8.4.4-fpm-alpine

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
    imagemagick \
    imagemagick-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    linux-headers \
    make \
    oniguruma-dev \
    openldap-dev \
    postgresql-dev \
    unzip \
    ${PHPIZE_DEPS} && \
    rm -rf /var/cache/apk/*

# Install and configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
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
RUN pecl install -o -f imagick xdebug && \
    docker-php-ext-enable imagick xdebug

# Configure PHP
RUN echo 'memory_limit=512M' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and group if they don't exist
RUN if ! getent group www-data >/dev/null; then \
    addgroup -g 1000 -S www-data; \
    fi && \
    if ! id -u $user >/dev/null 2>&1; then \
    adduser -u $uid -D -S -G www-data $user; \
    fi && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:www-data /home/$user

WORKDIR /var/www/app

USER ${user}
FROM php:7.2-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    git \
    libfreetype6-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libldap2-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Install and configure PHP extensions
RUN pecl install xdebug-2.9.2 && \
    docker-php-ext-enable xdebug

# Configure PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-webp-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Install PHP extensions
RUN docker-php-ext-install \
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

# Set PHP memory limit
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and set permissions
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER ${user}
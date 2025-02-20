FROM php:8.3-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    g++ \
    git \
    libfreetype6-dev \
    libgmp-dev \
    libjpeg62-turbo-dev \
    libldap2-dev \
    libmagickwand-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libwebp-dev \
    libxml2-dev \
    libzip-dev \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN pecl install imagick xdebug redis && \
    docker-php-ext-enable imagick xdebug redis

# Configure and install GD
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    cd /usr/src/php/ext/gd && make

# Configure and install PostgreSQL
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    gd \
    gettext \
    gmp \
    intl \
    ldap \
    mbstring \
    ftp\
    mysqli \
    opcache \
    pcntl \
    pdo_mysql \
    pdo_pgsql \
    pgsql \
    sockets \
    zip

# Configure PHP
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and set permissions
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER ${user}
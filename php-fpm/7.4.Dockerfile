FROM php:7.4-fpm

# Arguments defined in docker-compose.yml
ARG uid=1000
ARG user=app

# Install system packages - Split into multiple RUN commands to handle ARM64 QEMU issues
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    unzip

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    libpng-dev \
    libonig-dev \
    libzip-dev

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libldap2-dev \
    libxml2-dev \
    libwebp-dev \
    libgmp-dev

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libmagickwand-dev \
    libjpeg62-turbo-dev \
    g++; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

# Install PHP extensions one at a time to reduce memory pressure
RUN pecl install imagick
RUN docker-php-ext-enable imagick
RUN pecl install xdebug-3.1.5
RUN docker-php-ext-enable xdebug
RUN pecl install redis
RUN docker-php-ext-enable redis

# Configure and install GD with reduced parallelism for ARM64
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j2 gd

# Configure and install PostgreSQL with reduced parallelism
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
    docker-php-ext-install -j2 pgsql pdo_pgsql

# Install remaining PHP extensions in smaller batches with reduced parallelism
RUN docker-php-ext-install -j2 gettext zip pdo_mysql mbstring
RUN docker-php-ext-install -j2 intl exif pcntl bcmath
RUN docker-php-ext-install -j2 gmp mysqli ldap
RUN docker-php-ext-install -j2 opcache sockets

# Set PHP memory limit
RUN echo 'memory_limit=2G' > /usr/local/etc/php/conf.d/memory-limit.ini

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user
RUN useradd -G www-data,root -u $uid -d /home/$user $user && \
    mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www/app

USER ${user}